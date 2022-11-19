import datetime as dt
from functools import wraps

import requests
import flask as fl
# from flask_cors import CORS
from models import db, User, Account, Currency, Transaction
import jwt

app = fl.Flask(__name__)
# CORS(app)

app.config['SECRET_KEY'] = 'secret!'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/sovcombank'
db.init_app(app)
with app.app_context():
    db.create_all()


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'x-access-token' in fl.request.headers:
            token = fl.request.headers['x-access-token']
        if not token:
            return {'message': 'Token is missing !!'}, 401
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'])
            current_user = User.query \
                .filter_by(id=data['user_id']) \
                .first()
        except:
            return {'message': 'Token is invalid !!'}, 401
        # returns the current logged in users contex to the routes
        return f(current_user, *args, **kwargs)

    return decorated


@app.route('/api/users/login', methods=['POST'])
def user_login():
    auth = fl.request.json
    if not auth or not auth.get('phone') or not auth.get('password'):
        # returns 401 if any email or / and password is missing
        return fl.make_response(
            'Could not verify',
            400,
            {'WWW-Authenticate': 'Basic realm ="Login required !!"'}
        )
    user = User.query \
        .filter_by(phone=auth.get('phone')) \
        .first()
    if not user:
        return fl.make_response(
            'Could not verify',
            401,
            {'WWW-Authenticate': 'Basic realm ="User does not exist !!"'}
        )

    if user.verify_password(auth.get('password')):
        if user.status != 'active':
            fl.make_response(
                'User was not activated',
                403,
                {'WWW-Authenticate': 'Basic realm ="User was not activated !!"'}
            )

        # generates the JWT Token
        token = jwt.encode({
            'user_id': user.id,
            'exp': dt.datetime.utcnow() + dt.timedelta(days=1)
        }, app.config['SECRET_KEY'])
        return fl.make_response({'token': token}, 201)
    # returns 403 if password is wrong
    return fl.make_response(
        'Could not verify',
        403,
        {'WWW-Authenticate': 'Basic realm ="Wrong Password !!"'}
    )


@app.route('/index/')
def index():
    return 'hello'


@app.route('/api/employees/login/', methods=['POST'])
def employee_login():
    try:
        phone = fl.request.json['phone']
        password = fl.request.json['password']
    except KeyError:
        fl.abort(400)
        return
    if phone == '89876543210' and password == 'admin':
        return {'status': 'OK'}
    return fl.Response(status=403)


@app.route('/api/users/', methods=['GET', 'POST'])
def users():
    if fl.request.method == 'POST':
        try:
            phone = fl.request.json.get('phone')
            passport = fl.request.json.get('passport')
            first_name = fl.request.json.get('first_name')
            second_name = fl.request.json.get('second_name')
            father_name = fl.request.json.get('father_name')
            password = fl.request.json.get('password')
        except KeyError:
            fl.abort(400)
            return
        if any(map(lambda s: s == '', [phone, passport, first_name, second_name, password])):
            fl.abort(400)
            return
        user = User.query.filter_by(phone=phone)
        if user:
            return {'error': 'user already exists'}, 403
        user = User(
            phone=phone,
            passport=passport,
            first_name=first_name,
            second_name=second_name,
            father_name=father_name,
            status='pending'
        )
        user.hash_password(password)
        db.session.add(user)
        db.session.commit()
        return user.json
    if fl.request.method == 'GET':
        status = fl.request.args.get('status', None)
        if status:
            users = User.query.filter_by(status=status).all()
        else:
            users = User.query.filter(User.status != 'pending').filter(User.status != 'declined')
        return [user.json for user in users]


@app.route('/api/users/<user_id>/', methods=['GET', 'PATCH', 'DELETE'])
def user_handler(user_id: int):
    try:
        user_id = int(user_id)
    except ValueError:
        fl.abort(400)
    user = User.query.get(user_id)
    if not user:
        return {'error': f'user with id {user_id} not found'}, 404
    if fl.request.method == 'GET':
        return user.json
    if fl.request.method == 'PATCH':
        status = fl.request.json.get('status', '')
        if not status:
            return {"error": 'no status provided'}, 400
        if status == 'active':
            user_id = int(user_id)
            if not user.accounts:
                account = Account(currency_id=1, amount=0, user_id=user_id)
                db.session.add(account)
        user.status = status
    if fl.request.method == 'DELETE':
        user.status = 'delete'
    db.session.add(user)
    db.session.commit()
    return user.json


@app.route('/api/accounts/', methods=['GET', 'POST'])
def accounts_handler():
    if fl.request.method == 'GET':
        if user_id := fl.request.args.get('user_id', None):
            accounts = Account.query.filter_by(user_id=user_id)
        else:
            accounts = Account.query.all()
        return [account.json for account in accounts]
    if fl.request.method == "POST":
        currency_id = fl.request.json.get('currency_id')
        amount = 0
        user_id = fl.request.json.get('user_id')
        account = Account(currency_id=currency_id, amount=amount, user_id=user_id)
        db.session.add(account)
        db.session.commit()
        return account.json


@app.route('/api/transactions', methods=['GET', 'POST'])
@token_required
def transactions_handler():
    if fl.request.method == 'GET':
        if user_id := fl.request.args.get('user_id', None):
            accounts = Account.query.filter_by(user_id=user_id)
        else:
            accounts = Account.query.all()
        return [account.json for account in accounts]
    if fl.request.method == 'POST':
        from_account_id = fl.request.json.get('from_account_id', None)
        to_account_id = fl.request.json.get('to_account_id', None)
        from_value = fl.request.json.get('from_value', None)
        to_value = fl.request.json.get('to_value', None)
        if not (from_account_id and to_account_id and (from_value or to_value)):
            return {}, 404
        from_account = Account.query.get(from_account_id)
        to_account = Account.query.get(to_account_id)
        currencies = (from_account.currency.tag, to_account.currency.tag)
        if from_value is None and to_value:
            from_value, to_value = (to_value, from_value)
            currencies = (currencies[1], currencies[0])
            url = f'https://api.apilayer.com/currency_data/convert?from={currencies[0]}&to={currencies[1]}&amount={from_value}'
            headers = {"apikey": "EF7FlFQECktMxQLiVtc87Edy9pW0Frvd"}
            res = requests.get(url, headers=headers)
            if res.status_code != 200:
                return {'error': 'Error fetching currency'}, 500
            result = res.json()
            transaction = Transaction(
                from_account_id=from_account_id,
                to_account_id=to_account_id,
                from_value=from_value,
                to_value=result['result'],
                exchange_rate=result['info']['quote'],
                timestamp=dt.datetime.utcnow()
            )
            db.session.add(transaction)
            db.session.commit()
            return transaction.json


@app.route('/api/currencies', methods=['GET'])
def currencies_handler():
    base_tag = fl.request.args.get('base_tag', 'RUB')
    url = f"https://api.apilayer.com/currency_data/live?source={base_tag}"
    headers = {"apikey": "EF7FlFQECktMxQLiVtc87Edy9pW0Frvd"}
    response = requests.request("GET", url, headers=headers)
    result = response.json()['quotes']
    for key in result:
        result[key[:3]] = result.pop(key)
    return list(result.items())


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084, debug=True)

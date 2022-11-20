import datetime as dt
from functools import wraps

import requests
import flask as fl
# from flask_cors import CORS
from models import db, User, Account, Currency, Transaction, Employee, Cash
import jwt
from config import SECRET_KEY, APILAYER_KEY

app = fl.Flask(__name__)
# CORS(app)

app.config['SECRET_KEY'] = SECRET_KEY
app.config['APILAYER_KEY'] = APILAYER_KEY
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
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            current_user = User.query \
                .filter_by(id=data['user_id']) \
                .first()
        except:
            return {'message': 'Token is invalid !!'}, 401
        # returns the current logged in users contex to the routes
        return f(*args, **kwargs)

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


@app.route('/api/employees/login/', methods=['POST'])
def employee_login():
    auth = fl.request.json
    if not auth or not auth.get('phone') or not auth.get('password'):
        # returns 401 if any email or / and password is missing
        return fl.make_response(
            'Could not verify',
            400,
            {'WWW-Authenticate': 'Basic realm ="Login required !!"'}
        )
    employee = Employee.query \
        .filter_by(phone=auth.get('phone')) \
        .first()
    if not employee:
        return fl.make_response(
            'Could not verify',
            401,
            {'WWW-Authenticate': 'Basic realm ="User does not exist !!"'}
        )

    if employee.verify_password(auth.get('password')):
        # generates the JWT Token
        token = jwt.encode({
            'user_id': employee.id,
            'exp': dt.datetime.utcnow() + dt.timedelta(days=1)
        }, app.config['SECRET_KEY'])
        return fl.make_response({'token': token}, 201)
    # returns 403 if password is wrong
    return fl.make_response(
        'Could not verify',
        403,
        {'WWW-Authenticate': 'Basic realm ="Wrong Password !!"'}
    )


@app.route('/api/users/', methods=['GET'])
@token_required
def get_users():
    status = fl.request.args.get('status', None)
    if status:
        users = User.query.filter_by(status=status).all()
    else:
        users = User.query.filter(User.status != 'pending').filter(User.status != 'declined')
    return [user.json for user in users]


@app.route('/api/users/', methods=['POST'])
def users():
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
    user = User.query.filter_by(phone=phone).first()
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


@app.route('/api/users/<user_id>/', methods=['GET', 'PATCH', 'DELETE'])
@token_required
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
            print(fl.request.json)
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
@token_required
def accounts_handler():
    if fl.request.method == 'GET':
        if user_id := fl.request.args.get('user_id', None):
            accounts = Account.query.filter_by(user_id=user_id)
        else:
            accounts = Account.query.all()
        return [account.json for account in accounts], 200
    if fl.request.method == "POST":
        try:
            currency_id = fl.request.json.get('currency_id')
            user_id = fl.request.json.get('user_id')
        except KeyError:
            return {'error': 'invalid response'}, 400
        amount = 0
        account = Account(currency_id=currency_id, amount=amount, user_id=user_id)
        db.session.add(account)
        db.session.commit()
        return account.json, 201


@app.route('/api/cash', methods=['GET', 'POST'])
@token_required
def cash_handler():
    print(fl.request.json)
    if fl.request.method == 'GET':
        if account_id := fl.request.args.get('account_id', None):
            cash = Cash.query.filter_by(account_id=account_id)
        else:
            cash = Cash.query.all()
        return [c.json for c in cash], 200
    if fl.request.method == 'POST':
        account_id = fl.request.json.get('account_id')
        value = fl.request.json.get('value')
        if account_id is None or not isinstance(value, int):
            return {'error': f'Invalid data'}, 400
        account = Account.query.get(account_id)
        if not account:
            return {'error': f'No such account with id = {account_id}'}, 404
        if account.amount + value < 0:
            return {'error': 'Not enough amount on account'}, 403
        account.amount += value
        cash = Cash(account_id=account_id, value=value)
        db.session.add(account)
        db.session.add(cash)
        db.session.commit()
        return cash.json, 200


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
        sell_account_id = fl.request.json.get('sell_account_id', None)
        buy_account_id = fl.request.json.get('buy_account_id', None)
        sell_value = fl.request.json.get('sell_value', None)
        buy_value = fl.request.json.get('buy_value', None)
        if not (sell_account_id and buy_account_id and (bool(sell_value) != bool(buy_value))):
            return {'error': 'Not enough parameters'}, 400
        sell_account = Account.query.get(sell_account_id)
        buy_account = Account.query.get(buy_account_id)
        currencies = (sell_account.currency.tag, buy_account.currency.tag)

        value = sell_value or buy_value
        url = f'https://api.apilayer.com/currency_data/convert?from={currencies[0]}&to={currencies[1]}&amount={value}'
        headers = {"apikey": app.config['APILAYER_KEY']}
        res = requests.get(url, headers=headers)
        if res.status_code != 200:
            return {'error': 'Error fetching currency'}, 500
        result = res.json()
        if buy_value:
            sell_value = round(result['result'])
        else:
            buy_value = round(result['result'])
        if sell_value > sell_account.amount:
            return {'error': 'Not enough amount to sell'}, 403
        sell_account.amount -= sell_value
        buy_account.amount += buy_value
        transaction = Transaction(
            selll_account_id=sell_account_id,
            buy_account_id=buy_account_id,
            sell_value=sell_value,
            buy_value=buy_value,
            exchange_rate=result['info']['quote'],
            timestamp=dt.datetime.utcnow()
        )
        db.session.add(sell_account)
        db.session.add(buy_account)
        db.session.add(transaction)
        db.session.commit()
        return transaction.json


@app.route('/api/currencies', methods=['GET'])
@token_required
def currencies_handler():
    base_tag = fl.request.args.get('base_tag', 'RUB')
    url = f"https://api.apilayer.com/currency_data/live?source={base_tag}"
    headers = {"apikey": app.config['APILAYER_KEY']}
    response = requests.request("GET", url, headers=headers)
    result = response.json()['quotes']
    return [{'tag': key[3:], 'rate': rate} for key, rate in result.items()]


@app.route('/api/currencies/<tag>', methods=['GET'])
@token_required
def currency_handler(tag):
    currency = Currency.query.filter_by(tag=tag).first()
    if not currency:
        return {'error': 'incorrect tag'}, 400

    base_tag = fl.request.args.get('base_tag', 'RUB' if currency.tag != 'RUB' else 'USD')
    timedelta = fl.request.args.get('timedelta', 365)
    start_date = fl.request.args.get('start_date',
                                     dt.date.today() - dt.timedelta(days=timedelta))
    end_date = fl.request.args.get('end_date', dt.date.today())
    url = f"https://api.apilayer.com/currency_data/timeframe" \
          f"?start_date={start_date}" \
          f"&end_date={end_date}" \
          f"&source={base_tag}" \
          f"&currencies={currency.tag}"
    headers = {"apikey": app.config['APILAYER_KEY']}
    response = requests.get(url, headers)
    if response.status_code != 200:
        return {'error': 'incorrect data'}, 400
    result = response.json()['quotes']
    for key, value in result.items():
        result[key] = value[base_tag + currency.tag]
    return result


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084, debug=True)

import flask as fl
from flask_cors import CORS
from models import db, User, Account, Currency
# from flask_httpauth import HTTPBasicAuth

app = fl.Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/sovcombank'
db.init_app(app)
with app.app_context():
    db.create_all()

# auth = HTTPBasicAuth()


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


@app.route('/api/currencies', methods=['POST'])
def currencies_handler():
    tag = fl.request.json.get('tag')
    name = fl.request.json.get('name')
    currency = Currency(tag=tag, name=name)
    db.session.add(currency)
    db.session.commit()
    return currency.json


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084, debug=True)

import flask as fl
from flask_cors import CORS
from models import db, User, Account
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
            users = User.query.filter(User.status != 'pending')
        return [user.json for user in users]


@app.route('/api/users/<user_id>/', methods=['GET', 'PATCH', 'DELETE'])
def user_handler(user_id: int):
    user = User.query.get(user_id)
    if not user:
        return {'error': f'user with id {user_id} not found'}, 404
    if fl.request.method == 'GET':
        return user.json
    if fl.request.method == 'PATCH':
        action = fl.request.args.get('action', '')
        if action == 'block':
            user.status = 'blocked'
        elif action == 'unblock':
            user.status = 'active'
        elif action == 'reject':
            user.status = 'rejected'
        elif action == 'activate':
            user_id = int(user_id)
            user = User.query.get(user_id)
            if not user:
                return {'error': f'user with id {user_id} not found'}, 404
            if user.status != 'pending':
                return {'error': 'user is already activated'}, 403
            account = Account(currency_id=1, amount=0, user_id=user_id)
            db.session.add(account)
            user.status = 'active'
        else:
            return {'error': 'action is not allowed'}, 403
    if fl.request.method == 'DELETE':
        user.status = 'delete'
    db.session.add(user)
    db.session.commit()
    return user.json


@app.route('/api/accounts/', methods=['GET', 'POST'])
def accounts():
    if fl.request.method == 'GET':
        accounts = Account.query.all()
        return [account.json for account in accounts]


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084, debug=True)

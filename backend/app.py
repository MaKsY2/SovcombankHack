import flask as fl
from flask_cors import CORS
from models import db, User
# from flask_httpauth import HTTPBasicAuth

app = fl.Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/sovcombank'
db.init_app(app)

# auth = HTTPBasicAuth()


@app.route('/index')
def index():
    return 'hello'


@app.route('/api/employees/login', methods=['POST'])
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


@app.route('/api/users/', methods=['POST'])
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
        return {
            "phone": user.phone,
            "passport": user.passport,
            "first_name": user.first_name,
            "second_name": user.second_name,
            "father_name": user.father_name,
            "status": user.status
        }


# @app.route('/users/<user_id>/activate', methods=['POST'])
# @auth.login_required
# def user_activate(user_id: int):
#     user = User.objects.get()


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084, debug=True)

import flask as fl
from flask_cors import CORS
from models import db


app = fl.Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/sovcombank'
db.init_app(app)


@app.route('/index')
def index():
    return 'hello'


@app.route('/api/employees/login')
def employee_login():
    return {"status": "OK"}


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084)

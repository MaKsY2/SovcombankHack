import flask as fl
from flask_cors import CORS


app = fl.Flask(__name__)
CORS(app)


@app.route('/index')
def index():
    return 'hello'


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8084)

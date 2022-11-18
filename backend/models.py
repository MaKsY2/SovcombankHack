from flask_sqlalchemy import SQLAlchemy
from passlib.apps import custom_app_context as pwd_context


db = SQLAlchemy()


class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(100), unique=True, nullable=False)
    passport = db.Column(db.String(10), unique=True, nullable=False)
    first_name = db.Column(db.String(100), nullable=False)
    second_name = db.Column(db.String(100), nullable=False)
    father_name = db.Column(db.String(100), default='')
    status = db.Column(db.String(100), default='pending')
    password_hash = db.Column(db.String(1000), nullable=False)

    def hash_password(self, password):
        self.password_hash = pwd_context.encrypt(password)

    def verify_password(self, password):
        return pwd_context.verify(password, self.password_hash)

    def __repr__(self):
        return f'User<{self.id}>'


class Currency(db.Model):
    __tablename__ = 'currencies'

    id = db.Column(db.Integer, primary_key=True)
    tag = db.Column(db.String(10), nullable=False, unique=True)
    name = db.Column(db.String(100), nullable=False)

    accounts = db.relationship("Account", back_populates="currency")


class Account(db.Model):
    __tablename__ = 'accounts'

    id = db.Column(db.Integer, primary_key=True)
    currency_id = db.Column(db.Integer, db.ForeignKey('currencies.id'))
    currency = db.relationship("Currency", uselist=False, back_populates="accounts")

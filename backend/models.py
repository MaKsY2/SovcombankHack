from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.sql import func
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

    accounts = db.relationship('Account', back_populates='user')

    def hash_password(self, password):
        self.password_hash = pwd_context.encrypt(password)

    def verify_password(self, password):
        return pwd_context.verify(password, self.password_hash)

    @property
    def json(self):
        return {
            "id": self.id,
            "phone": self.phone,
            "passport": self.passport,
            "first_name": self.first_name,
            "second_name": self.second_name,
            "father_name": self.father_name,
            "status": self.status
        }

    def __repr__(self):
        return f'User<{self.id}>'


class Currency(db.Model):
    __tablename__ = 'currencies'

    id = db.Column(db.Integer, primary_key=True)
    tag = db.Column(db.String(10), nullable=False, unique=True)
    name = db.Column(db.String(100), nullable=False)

    accounts = db.relationship("Account", back_populates="currency")

    @property
    def json(self):
        return {
            'id': self.id,
            'tag': self.tag,
            'name': self.name
        }


class Account(db.Model):
    __tablename__ = 'accounts'

    id = db.Column(db.Integer, primary_key=True)
    currency_id = db.Column(db.Integer, db.ForeignKey('currencies.id'))
    amount = db.Column(db.Float, default=0.0)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    currency = db.relationship('Currency', uselist=False, back_populates='accounts')
    user = db.relationship('User', uselist=False, back_populates='accounts')

    @property
    def json(self):
        return {
            'id': self.id,
            'currency': self.currency.json,
            'amount': self.amount,
            'user': self.user.json
        }


class Transaction(db.Model):
    __tablename__ = 'transactions'

    id = db.Column(db.Integer, primary_key=True)
    from_account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'))
    to_account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'))
    from_value = db.Column(db.Float, nullable=False)
    to_value = db.Column(db.Float, nullable=False)
    exchange_rate = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime(timezone=True), server_default=func.now())

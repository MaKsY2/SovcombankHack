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
            "status": self.status,
            'accounts': [account.json for account in self.accounts]
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
    amount = db.Column(db.DECIMAL, default=0.0)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    currency = db.relationship('Currency', uselist=False, back_populates='accounts')
    user = db.relationship('User', uselist=False, back_populates='accounts')

    @property
    def json(self):
        return {
            'id': self.id,
            'currency': self.currency.json,
            'amount': self.amount,
            'user_id': self.user_id
        }


class Transaction(db.Model):
    __tablename__ = 'transactions'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    sell_account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'))
    buy_account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'))
    sell_value = db.Column(db.DECIMAL, nullable=False)
    buy_value = db.Column(db.DECIMAL, nullable=False)
    exchange_rate = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime(timezone=True), server_default=func.now())

    user = db.relationship('User', foreign_keys=[user_id])
    sell_account = db.relationship('Account', foreign_keys=[sell_account_id])
    buy_account = db.relationship('Account', foreign_keys=[buy_account_id])

    @property
    def json(self):
        return {
            "id": self.id,
            "sell_account_id": self.sell_account_id,
            "buy_account_id": self.buy_account_id,
            "sell_value": self.sell_value,
            "buy_value": self.buy_value,
            "exchange_rate": self.exchange_rate,
            "timestamp": self.timestamp.isoformat()
        }


class Employee(db.Model):
    __tablename__ = 'employees'

    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(100), unique=True)
    password_hash = db.Column(db.String(1000), nullable=False)

    def hash_password(self, password):
        self.password_hash = pwd_context.encrypt(password)

    def verify_password(self, password):
        return pwd_context.verify(password, self.password_hash)


class Cash(db.Model):
    __tablename__ = 'cash'

    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id'))
    value = db.Column(db.DECIMAL, nullable=False)
    timestamp = db.Column(db.DateTime(timezone=True), server_default=func.now())

    @property
    def json(self):
        return {
            "id": self.id,
            "account_id": self.account_id,
            "value": self.value,
            "timestamp": self.timestamp.isoformat()
        }

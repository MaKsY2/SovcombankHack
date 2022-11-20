export interface User {
    "id": number,
    "phone": string,
    "passport": number,
    "first_name": string,
    "second_name": string,
    "father_name": string,
    "status": string
    "accounts": Account[]
}

export interface Account {
    "id": number,
    "user_id": number,
    "amount": number,
    "currency": Currency
}

export interface Currency {
    "tag": string,
    "name": string
}

export interface Transaction {
    "id": number,
    "sell_account_id": number,
    "buy_account_id": number,
    "sell_value": number,
    "buy_value": number,
    "exchange_rate": number,
    "timestamp": string,
    "sell_account": Account,
    "buy_account": Account
}

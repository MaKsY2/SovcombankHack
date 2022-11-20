import React, {FC} from "react";
import {Transaction} from "../types";

interface TransactionItemProps {
    transaction: Transaction;
}

const TransactionItem: FC<TransactionItemProps> = ({transaction}) => {
    const date = new Date(transaction.timestamp);
    const myDateString = ('0' + date.getUTCDate()).slice(-2) + '/'
        + ('0' + (date.getUTCMonth()+1)).slice(-2) + '/'
        + date.getUTCFullYear();
    const myTimeString = ('0' + date.getUTCHours()).slice(-2) + ':'
        + ('0' + (date.getUTCMinutes())).slice(-2) + ':'
        + ('0' + (date.getUTCSeconds())).slice(-2)
    return (
        <div className="inline-grid grid-cols-3 grid-rows-1 border-2 text-2xl py-3">
            <div className="text-center">
                {myDateString} {myTimeString}
            </div>
            <div className="text-center">
                {transaction.sell_value} {transaction.sell_account.currency.tag} {"->"} {transaction.buy_value} {transaction.buy_account.currency.tag}
            </div>
            <div className="text-center">Exchange rate: {transaction.exchange_rate}</div>
        </div>
    )
}

export default TransactionItem
import React, {FC} from "react";
import {Transaction} from "../types";
import TransactionItem from "./tramsactionItem";

interface TransactionListProp {
    transactions: Transaction[];
}

const TransactionList: FC<TransactionListProp> = ({transactions}) => {
    return (
        <div className="inline-grid grid-cols-1 w-full gap-3">
            {transactions.map(transaction => <TransactionItem transaction={transaction}/>)}
        </div>
    )
}

export default TransactionList
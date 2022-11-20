import React, {FC} from "react";
import {Account} from "../types";

interface AccountItemProps {
    account: Account;
}

const AccountItem: FC<AccountItemProps> = ({account}) => {
    return (
        <div className="flex border-2 text-2xl py-3">
            <div className="text-left w-[50%] pl-10">{account.currency.tag}</div>
            <div className="text-right w-[50%] pr-10">amount: {account.amount}</div>
        </div>
    )
}

export default AccountItem
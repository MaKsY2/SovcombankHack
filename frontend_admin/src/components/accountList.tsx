import React, {FC} from "react";
import {Account} from "../types";
import AccountItem from "./accountItem";

interface AccountListProp {
    accounts: Account[];
}


const AccountList: FC<AccountListProp> = ({accounts}) => {
    return (
        <div className="inline-grid grid-cols-3 w-full gap-3">
            {accounts.map(account => <AccountItem account={account}/>)}
        </div>
    )
}

export default AccountList
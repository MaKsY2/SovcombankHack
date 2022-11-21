import React, {FC, useState} from 'react';
import {User} from "../types";
import AccountList from "./accountList";
import TransactionList from "./transactionList";

interface UserItemProps{
    current_user: User;
}

const UserItem: FC<UserItemProps> = ({current_user}) => {

    const [clickedButton, setClickedButton] = useState('');
    let [transactions, setTransactions] = useState([]);
    let [user, setUser] = useState(current_user);

    const buttonHandler = async(event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();

        const button: HTMLButtonElement = event.currentTarget;

        try {
             let res = await fetch("https://sovcombank.scipie.ru/api/users/"+user.id+"/", {
                    method: "PATCH",
                    headers: {
                        "Content-Type": "application/json",
                        "x-access-token": sessionStorage.getItem("JWT") ?? ""
                    },
                    body: JSON.stringify({
                        status: button.name
                    }),
                });
             if (res.status === 200) {
                user.status = button.name
                setClickedButton(button.name);
            }
        } catch (err) {
            console.log(err);
        }
    };

    const detailsHandler = async (event: React.MouseEvent<HTMLDetailsElement>) => {
        event.preventDefault();

        const details: HTMLDetailsElement = event.currentTarget;
        if (!details.open) {
            try {
                let user_res = await fetch("https://sovcombank.scipie.ru/api/users/"+user.id+"/", {
                    method: "GET",
                    headers: {
                        "x-access-token": sessionStorage.getItem("JWT") ?? ""
                    }
                });
                current_user = await user_res.json();
                setUser(current_user);
                console.log(user);
                let res = await fetch(
                    "https://sovcombank.scipie.ru/api/transactions/?user_id=" + user.id,
                    {
                        method: "GET",
                        headers: {
                            "x-access-token": sessionStorage.getItem("JWT") ?? ""
                        }
                    }
                );
                if (res.status === 200) {
                    setTransactions(await res.json());
                    console.log(transactions);
                }
            } catch (err) {
                console.log(err);
            }
        }
        details.open = !details.open;
    }

    return (
        <div className="my-3 border-4 text-center font-bold w-[100%]">
            <details className="bg-gray-300 open:bg-amber-200 duration-300" onClick={detailsHandler}>
                <summary className="bg-inherit px-5 text-lg cursor-pointer list-none">
                    <p>ФИО: {user.second_name} {user.first_name} {user.father_name}</p>
                    <p>Номер телефона: {user.phone}</p>
                    <p>Пасспортные данные: {user.passport}</p>
                    <p>Статус: {user.status}</p>
                </summary>
                <div className="bg-white px-5 py-3 border border-gray-300 text-sm font-light">
                    <div>
                        <div className="text-3xl">Accounts</div>
                        <div>
                            <AccountList accounts={user.accounts}/>
                        </div>
                    </div>
                    <div>
                        <div className="text-3xl">Transactions</div>
                        <div>
                            <TransactionList transactions={transactions}/>
                        </div>
                    </div>
                </div>
            </details>
            {/*<p>{user.first_name}</p>*/}
            {/*<p>{user.status}</p>*/}
            {user.status === "blocked" && (
                <section>
                    <div className="inline-grid grid-cols-2 grid-rows-1 w-full grid-">
                        <button onClick={buttonHandler} className="button border-r-2 border-gray-300 bg-gray-200 py-2" name="active">
                            unblock
                        </button>
                        <button onClick={buttonHandler} className="button border-l-2 border-gray-300 bg-gray-200 py-2" name="deleted">
                            delete
                        </button>
                    </div>
                </section>
            )}
            {user.status === "active" && (
                <section>
                    <div className="inline-grid grid-cols-2 grid-rows-1 w-full grid-">
                        <button onClick={buttonHandler} className="button border-r-2 border-gray-300 bg-gray-200 py-2" name="blocked">
                            block
                        </button>
                        <button onClick={buttonHandler} className="button border-l-2 border-gray-300 bg-gray-200 py-2" name="deleted">
                            delete
                        </button>
                    </div>
                </section>
            )}
            {user.status === "deleted" && (
                <section>
                    <div className="inline-grid grid-cols-1 grid-rows-1 w-full grid-">
                        <button onClick={buttonHandler} className="border-gray-200 bg-gray-200 py-2" name="active">
                            restore
                        </button>
                    </div>
                </section>
            )}
            {user.status === "pending" && (
                <section>
                    <div className="inline-grid grid-cols-2 grid-rows-1 w-full grid-">
                        <button onClick={buttonHandler} className="button border-r-2 border-gray-300 bg-gray-200 py-2" name="active">
                            accept
                        </button>
                        <button onClick={buttonHandler} className="button border-l-2 border-gray-300 bg-gray-200 py-2" name="declined">
                            decline
                        </button>
                    </div>
                </section>
            )}
        </div>
    );
};

export default UserItem

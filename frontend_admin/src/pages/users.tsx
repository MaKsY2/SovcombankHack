import React, {PureComponent, useEffect, useState} from 'react';
import {Navigation} from "../components/navigation";
import {User} from "../types";
import axios from "axios";
import UserList from "../components/userList";

const UsersPage = () => {

    const [users, setUsers] = useState<User[]>([]);

    async function fetchUsers() {
        try {
            const config = {
                headers: {
                    "Content-Type": "application/json",
                    "x-access-token": sessionStorage.getItem("JWT") ?? ""
                }
            }
            const query: string = (' https://sovcombank.scipie.ru/api/users')
            const response = await axios.get<User[]>(query, config);
            setUsers(response.data)
            console.log(response.data)
        } catch (e) {
            alert(e)
        }
    }

    useEffect(() => {fetchUsers()}, []);
    if (users.length === 0) {
        return (
            <><Navigation/>
            </>
        )
    }
    return (
        <><Navigation/>
            <div>
                <UserList users={users}/>
            </div>
        </>
    );

}

export default UsersPage;
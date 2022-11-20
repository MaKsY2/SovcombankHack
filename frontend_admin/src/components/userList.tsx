import React, {FC, useEffect, useState} from 'react';
import {User} from "../types";
import UserItem from "./userItem";

interface UserListProps {
    users: User[];
}


const filterUsers = (searchText: any, listOfUsers: any) => {
    if (!searchText) {
        return listOfUsers;
    }
    return listOfUsers.filter(({ first_name, second_name, father_name}:
                                   {first_name:any, second_name:any,father_name:any}) =>
        (second_name + first_name + father_name).toLowerCase().includes(searchText.toLowerCase())
    );
}

const UserList: FC<UserListProps> = ({users}) => {

    const [searchTerm, setSearchTerm] = useState('');
    const [userList, setUserList] = useState(users);

    useEffect(() => {
        const Debounce = setTimeout(() => {
            const filteredUsers = filterUsers(searchTerm, users);
            setUserList(filteredUsers);
        }, 300);

        return () => clearTimeout(Debounce);
    }, [searchTerm]);

    return (
        <div className="flex-row container mx-auto font-mono px-14">
            <div className="text-3xl text-center py-3б">Поиск</div>
            <div className="text-3xl text-center py-3">
                <input
                    autoFocus
                    type="text"
                    autoComplete="off"
                    placeholder="Поиск пользователя"
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-100 text-stone-900 placeholder:italic placeholder:text-slate-400 block bg-white border border-slate-300 rounded-sm py-2 px-3 shadow-lg focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm mx-auto"
                    style={{
                        width: '600px',
                    }}
                />
            </div>
            <div className="text-3xl text-center py-3">
                <div className="justify-center align-middle">
                    {userList.map(user =>
                        <UserItem current_user={user}/>
                    )}
                </div>
            </div>
        </div>
    );
}

export default UserList;
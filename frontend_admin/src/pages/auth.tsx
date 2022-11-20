import React, {useState} from "react"
import { useNavigate } from "react-router-dom";

const IndexPage = () => {
    const [login, setLogin] = useState('')
    const [password, setPassword] = useState('')
    const [message, setMessage] = useState("");
    let navigate = useNavigate();

    let handleSubmit = async (e: React.ChangeEvent<any>) => {
        e.preventDefault();
        try {
            let res = await fetch("https://sovcombank.scipie.ru/api/employees/login/", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    phone: login,
                    password: password,
                }),
            });
            if (res.status === 201) {
                let resJson = await res.json();
                navigate('requests')
                sessionStorage.setItem("JWT", resJson.token)
            } else {
                setMessage("Some error occured");
            }
        } catch (err) {
            console.log(err);
        }
    };

    return (
        <div className="min-h-screen bg-green-900 flex flex-col items-start text-gray-900 antialiased relative">
            <div className="max-w-xl w-full mt-24 mb-24 rounded-lg shadow-2xl bg-white mx-auto overflow-hidden z-10">
                <div className="px-16 py-10">
                    <form onSubmit={handleSubmit}>
                        <label htmlFor="login">login</label>
                        <input
                            type="text"
                            id="login"
                            name="login"
                            className="border-2 rounded-2xl text-center mt-4 w-[150px] h-[40px]"
                            //onChange={event => setTempLogin(event.target.value)}
                            onChange={(e) => setLogin(e.target.value)}
                        />
                        <label htmlFor="address">password</label>
                        <input
                            type="text"
                            id="address"
                            name="address"
                            className="border-2 rounded-2xl text-center mt-4 w-[150px] h-[40px]"
                            placeholder="enter password"
                            //onChange={event => setTempPassword(event.target.value)}
                            onChange={(e) => setPassword(e.target.value)}
                        />
                        <button
                            type="submit"
                            className="mt-6 bg-green-600 text-white rounded px-8 py-6 w-full disabled:bg-gray-400 disabled:cursor-not-allowed"
                            // onChange={event => setAdmin(tempLogin, tempPassword)}
                        >
                            войти
                        </button>
                        <div className="message">{message ? <p>{message}</p> : null}</div>
                    </form>
                </div>
            </div>
        </div>
    )
}

export default IndexPage
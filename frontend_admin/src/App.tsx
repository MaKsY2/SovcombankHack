import React from 'react';
import IndexPage from "./pages/auth";
import UsersPage from "./pages/users";
import RequestsPage from "./pages/requests";
import {BrowserRouter, Route, Routes} from "react-router-dom";

function App() {
  return (
    <>
        <Routes>
            <Route path="/" element={<IndexPage/>}/>
            <Route path="/users" element={<UsersPage/>}/>
            <Route path="/requests" element={<RequestsPage/>}/>
        </Routes>
    </>
  );
}

export default App;

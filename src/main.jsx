import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.jsx";
import { BookmarksProvider } from "./context/BookmarksContext.jsx";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <BookmarksProvider>
      <App />
    </BookmarksProvider>
  </React.StrictMode>
);

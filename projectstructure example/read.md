# FERN To-Do App – MVC Project Structure

Author: Nikko Gabriel Hismaña
CMSC 129 Unit 1 Lecture Example

This document shows a recommended project and file organization for a
To-Do List web application using the **FERN stack (Firebase, Express, React, Node)**
and following the **MVC (Model–View–Controller)** architectural pattern.

---

## High-Level Structure

```text
todo-fern/
├── client/          # React frontend (View)
└── server/          # Node/Express backend (Model + Controller)
```

# Frontend - React (View)

Responsible for:

- Displaying the user interface
- Collecting user input
- Sending requests to the backend (server: node/express)

```text
client/
├── src/
│   ├── components/
│   │   ├── TodoForm.jsx        # Form for creating/updating todos
│   │   ├── TodoItem.jsx        # Single todo item
│   │   └── TodoList.jsx        # List of todos
│   │
│   ├── pages/
│   │   └── Home.jsx            # Main page
│   │
│   ├── services/
│   │   └── todoApi.js          # API calls to backend (fetch/axios)
│   │
│   ├── App.jsx                 # App root component
│   └── main.jsx                # React entry point
│
├── public/
│   └── index.html
│
└── package.json
```

# Backend - Express/Node

Responsible for Model and Controller parts of the MVC pattern:

```text
server/
├── src/
│   ├── controllers/
│   │   └── todoController.js   # Handles HTTP requests and responses
│   │
│   ├── models/
│   │   └── todoModel.js        # Firebase CRUD logic and data rules
│   │
│   ├── routes/
│   │   └── todoRoutes.js       # Maps routes to controllers
│   │
│   ├── config/
│   │   └── firebase.js         # Firebase configuration and initialization
│   │
│   ├── app.js                  # Express app setup (middleware, routes)
│   └── server.js               # Server entry point
│
└── package.json
```

# MVC Responsibilities:

## Model

- Defines data structure and rules (Firebase schema)
- Interacts with Firebase
- Contains business rules

```text
server/src/models/todoModel.js
```

## Controller

- Handles HTTP requests and responses
- Validates input
- Calls Model functions
- Sends HTTP responses (success/error)

```text
server/src/controllers/todoController.js
```

## View

- Displays data (UI)
- Handles user interactions (forms, buttons)
- Sends requests to controller via HTTP (fetch/axios)

```text
client/src/components/
```

## Example Request Flow (Create To-Do):

1. User submits form in React (View)
2. React sends POST request to backend
3. Express route forwards request to controller
4. Controller validates input
5. Controller calls model
6. Model saves data to Firebase
7. Response sent back to frontend
8. React updates UI based on response

## Summary:

MVC in FERN is split across frontend and backend:
React = View,
Express = Controller,
Firebase logic = Model

from fastapi import FastAPI
from typing import List, Dict, Any

app = FastAPI()

# In-memory database for demonstration
db: List[Dict[str, Any]] = []

@app.get("/")
def read_root():
    return {"message": "Welcome to the Todo API!"}

@app.get("/todos")
def get_todos():
    return db

@app.post("/todos")
def create_todo(todo: Dict[str, Any]):
    db.append(todo)
    return todo

@app.get("/todos/{todo_id}")
def get_todo(todo_id: int):
    return db[todo_id]

@app.put("/todos/{todo_id}")
def update_todo(todo_id: int, todo: Dict[str, Any]):
    db[todo_id] = todo
    return todo

@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: int):
    db.pop(todo_id)
    return {"message": "Todo deleted"}

import os
from typing import List, Optional
from uuid import uuid4

import boto3
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI()

# DynamoDB connection
DYNAMODB_TABLE_NAME = os.environ.get("DYNAMODB_TABLE_NAME", "todo-items")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(DYNAMODB_TABLE_NAME)


# Pydantic Models for Todo Items
class TodoItem(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    title: str
    description: Optional[str] = None
    completed: bool = False


class TodoItemUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None


@app.get("/")
def read_root():
    return {"message": "Welcome to the Todo API!"}


# ------------------------------------------------------------------------------
# CRUD Endpoints for Todo Items
# ------------------------------------------------------------------------------

@app.post("/todos", response_model=TodoItem)
def create_todo(todo: TodoItem):
    """
    Create a new todo item.
    """
    item = todo.dict()
    table.put_item(Item=item)
    return item


@app.get("/todos", response_model=List[TodoItem])
def read_todos():
    """
    Retrieve all todo items.
    """
    response = table.scan()
    return response.get("Items", [])


@app.get("/todos/{todo_id}", response_model=TodoItem)
def read_todo(todo_id: str):
    """
    Retrieve a single todo item by its ID.
    """
    response = table.get_item(Key={"id": todo_id})
    item = response.get("Item")
    if not item:
        raise HTTPException(status_code=404, detail="Todo not found")
    return item


@app.put("/todos/{todo_id}", response_model=TodoItem)
def update_todo(todo_id: str, todo: TodoItemUpdate):
    """
    Update a todo item.
    """
    update_expression = "SET "
    expression_attribute_values = {}
    expression_attribute_names = {}

    update_data = todo.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")

    for key, value in update_data.items():
        update_expression += f"#{key} = :{key}, "
        expression_attribute_values[f":{key}"] = value
        expression_attribute_names[f"#{key}"] = key

    update_expression = update_expression.rstrip(", ")

    try:
        response = table.update_item(
            Key={"id": todo_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values,
            ExpressionAttributeNames=expression_attribute_names,
            ReturnValues="ALL_NEW",
        )
        return response["Attributes"]
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        raise HTTPException(status_code=404, detail="Todo not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.delete("/todos/{todo_id}", response_model=dict)
def delete_todo(todo_id: str):
    """
    Delete a todo item.
    """
    try:
        table.delete_item(Key={"id": todo_id}, ConditionExpression="attribute_exists(id)")
        return {"message": "Todo deleted successfully"}
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        raise HTTPException(status_code=404, detail="Todo not found")
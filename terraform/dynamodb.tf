resource "aws_dynamodb_table" "todo_items" {
  name         = "${var.project_name}-todo-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-todo-items"
  }
}

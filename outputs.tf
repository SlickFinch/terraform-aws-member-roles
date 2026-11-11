output "stack_set_name" {
  description = "Name of the StackSet."
  value       = aws_cloudformation_stack_set.this.name
}

output "stack_set_id" {
  description = "ID of the StackSet."
  value       = aws_cloudformation_stack_set.this.stack_set_id
}

output "role_name" {
  description = "Name of the IAM role in every member account."
  value       = var.role_name
}

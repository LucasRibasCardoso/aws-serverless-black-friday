resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "/aws/lambda/${var.function_name}"
  })
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  filename         = var.source_path
  source_code_hash = var.source_code_hash != null ? var.source_code_hash : filebase64sha256(var.source_path)
  handler          = var.handler
  # tflint-ignore: aws_lambda_function_invalid_runtime
  runtime       = var.runtime
  architectures = var.architectures
  memory_size   = var.memory_size
  timeout       = var.timeout

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []

    content {
      variables = var.environment_variables
    }
  }

  tags = merge(var.tags, {
    Name = var.function_name
  })

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy.cloudwatch_logs,
    aws_iam_role_policy.extra,
  ]
}

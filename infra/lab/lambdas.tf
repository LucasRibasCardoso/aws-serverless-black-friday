# Empacotamento (.zip) dos bundles gerados por `npm --prefix backend run bundle`

data "archive_file" "lambda_controller" {
  type        = "zip"
  source_file = "${path.module}/../../backend/dist/bundles/lambda-controller/control.mjs"
  output_path = "${path.module}/../../backend/dist/lambda-controller.zip"
}

data "archive_file" "lambda_generator" {
  type        = "zip"
  source_file = "${path.module}/../../backend/dist/bundles/lambda-generator/generator.mjs"
  output_path = "${path.module}/../../backend/dist/lambda-generator.zip"
}

data "archive_file" "lambda_processor" {
  type        = "zip"
  source_file = "${path.module}/../../backend/dist/bundles/lambda-processor/processor.mjs"
  output_path = "${path.module}/../../backend/dist/lambda-processor.zip"
}

# --- Lambda Generator ---
data "aws_iam_policy_document" "lambda_generator" {
  statement {
    sid       = "DynamoDBWrite"
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.this.arn]
  }
}

module "lambda_generator" {
  source = "../modules/lambda-function"

  function_name         = "${local.name_prefix}-generator"
  source_path           = data.archive_file.lambda_generator.output_path
  source_code_hash      = data.archive_file.lambda_generator.output_base64sha256
  handler               = "generator.handler"
  memory_size           = 1024
  timeout               = 660
  log_retention_in_days = var.lambda_log_retention_in_days

  environment_variables = {
    TABLE = aws_dynamodb_table.this.name
  }

  attach_policy = true
  policy_json   = data.aws_iam_policy_document.lambda_generator.json
}

resource "aws_lambda_function_event_invoke_config" "generator" {
  function_name          = module.lambda_generator.function_name
  maximum_retry_attempts = 0
}

# --- Lambda Controller ---
data "aws_iam_policy_document" "lambda_controller" {
  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
    ]
    resources = [aws_dynamodb_table.this.arn]
  }

  statement {
    sid       = "InvokeGenerator"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.lambda_generator.arn]
  }

  statement {
    sid     = "SQSReadAttributes"
    effect  = "Allow"
    actions = ["sqs:GetQueueAttributes"]
    resources = [
      aws_sqs_queue.order.arn,
      aws_sqs_queue.order_dlq.arn,
    ]
  }
}

module "lambda_controller" {
  source = "../modules/lambda-function"

  function_name         = "${local.name_prefix}-controller"
  source_path           = data.archive_file.lambda_controller.output_path
  source_code_hash      = data.archive_file.lambda_controller.output_base64sha256
  handler               = "control.handler"
  memory_size           = 512
  timeout               = 30
  log_retention_in_days = var.lambda_log_retention_in_days

  environment_variables = {
    TABLE     = aws_dynamodb_table.this.name
    QUEUE     = aws_sqs_queue.order.url
    DLQ       = aws_sqs_queue.order_dlq.url
    GENERATOR = module.lambda_generator.function_name
  }

  attach_policy = true
  policy_json   = data.aws_iam_policy_document.lambda_controller.json
}

# --- Lambda Processor ---
data "aws_iam_policy_document" "lambda_processor" {
  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.this.arn]
  }

  statement {
    sid    = "SQSConsume"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.order.arn]
  }
}

module "lambda_processor" {
  source = "../modules/lambda-function"

  function_name         = "${local.name_prefix}-processor"
  source_path           = data.archive_file.lambda_processor.output_path
  source_code_hash      = data.archive_file.lambda_processor.output_base64sha256
  handler               = "processor.handler"
  memory_size           = 512
  timeout               = 30
  log_retention_in_days = var.lambda_log_retention_in_days

  environment_variables = {
    TABLE = aws_dynamodb_table.this.name
  }

  attach_policy = true
  policy_json   = data.aws_iam_policy_document.lambda_processor.json
}

resource "aws_lambda_event_source_mapping" "processor_sqs" {
  event_source_arn        = aws_sqs_queue.order.arn
  function_name           = module.lambda_processor.arn
  batch_size              = var.lambda_processor_batch_size
  function_response_types = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = var.lambda_processor_max_concurrency
  }
}

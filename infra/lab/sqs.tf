resource "aws_sqs_queue" "order_dlq" {
  name                    = "${local.name_prefix}-orders-dlq.fifo"
  fifo_queue              = true
  sqs_managed_sse_enabled = true

  tags = {
    Name = "${local.name_prefix}-orders-dlq"
  }
}

resource "aws_sqs_queue" "order" {
  name                        = "${local.name_prefix}-orders.fifo"
  fifo_queue                  = true
  sqs_managed_sse_enabled     = true
  content_based_deduplication = false
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"
  visibility_timeout_seconds  = var.sqs_message_visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = {
    Name = "${local.name_prefix}-orders"
  }
}

resource "aws_sqs_queue_redrive_allow_policy" "this" {
  queue_url = aws_sqs_queue.order_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.order.arn]
  })
}

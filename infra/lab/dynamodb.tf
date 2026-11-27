resource "aws_dynamodb_table" "this" {
  name         = "${local.name_prefix}-main"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  on_demand_throughput {
    max_read_request_units  = var.dynamodb_max_read_request_units
    max_write_request_units = var.dynamodb_max_write_request_units
  }

  tags = {
    Name = "${local.name_prefix}-main"
  }
}

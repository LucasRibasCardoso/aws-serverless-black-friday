# Módulo `lambda-function`

Provisiona uma função **AWS Lambda** junto com os recursos padrão acoplados a ela:

- **IAM Role dedicada** com *trust policy* para `lambda.amazonaws.com`
- **CloudWatch Log Group** criado explicitamente com retenção configurável
- **Política IAM de logs** restrita ao Log Group da própria função (*Least Privilege*)
- **Política IAM extra opcional** (`policy_json`) para permissões específicas da função

Integrações e gatilhos específicos (como Event Source Mapping do SQS, integrações de API Gateway ou configuração de invocação assíncrona) ficam fora do módulo, no *root module* que o consome.

## Exemplo de uso

```hcl
data "aws_iam_policy_document" "processor" {
  statement {
    sid       = "DynamoDBAccess"
    actions   = ["dynamodb:GetItem", "dynamodb:BatchGetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.this.arn]
  }

  statement {
    sid       = "SQSConsume"
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.order.arn]
  }
}

module "lambda_processor" {
  source = "../modules/lambda-function"

  function_name         = "${local.name_prefix}-processor"
  description           = "Consome pedidos da fila SQS FIFO e abate estoque transacionalmente."
  source_path           = data.archive_file.processor.output_path
  source_code_hash      = data.archive_file.processor.output_base64sha256
  handler               = "lambda-processor/processor.handler"
  memory_size           = 512
  timeout               = 30
  log_retention_in_days = var.lambda_log_retention_in_days

  environment_variables = {
    TABLE_NAME = aws_dynamodb_table.this.name
  }

  attach_policy = true
  policy_json   = data.aws_iam_policy_document.processor.json
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.17 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_policy_document.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_role_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_architectures"></a> [architectures](#input\_architectures) | Arquitetura de CPU da função Lambda (arm64 ou x86\_64). | `list(string)` | <pre>[<br/>  "x86_64"<br/>]</pre> | no |
| <a name="input_attach_policy"></a> [attach\_policy](#input\_attach\_policy) | Indica se a política IAM extra (policy\_json) deve ser anexada à role da função. | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Variáveis de ambiente injetadas na função Lambda. | `map(string)` | `{}` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Nome completo da função Lambda (usado também como base para a IAM Role e o Log Group). | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Ponto de entrada (handler) da função Lambda (ex.: lambda-processor/processor.handler). | `string` | n/a | yes |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Tempo de retenção dos logs da função no CloudWatch Logs, em dias. | `number` | `7` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Quantidade de memória alocada para a função Lambda, em MB. | `number` | `512` | no |
| <a name="input_policy_json"></a> [policy\_json](#input\_policy\_json) | Documento JSON de política IAM inline com permissões adicionais (além dos logs no CloudWatch) para a role da função. Usado quando attach\_policy = true. | `string` | `null` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime utilizado pela função Lambda. | `string` | `"nodejs26.x"` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | Hash Base64 SHA-256 do pacote .zip (ex.: output\_base64sha256 de archive\_file). Se nulo, é calculado automaticamente a partir de source\_path. | `string` | `null` | no |
| <a name="input_source_path"></a> [source\_path](#input\_source\_path) | Caminho local do arquivo .zip contendo o pacote da função Lambda. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags extras aplicadas aos recursos criados pelo módulo (Name, Project e ManagedBy são gerenciadas automaticamente). | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Tempo máximo de execução da função Lambda, em segundos. | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN da função Lambda. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Nome da função Lambda. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | ARN de invocação da função Lambda (usado em integrações como API Gateway). |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN do CloudWatch Log Group da função Lambda. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Nome do CloudWatch Log Group da função Lambda. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN da IAM Role de execução da função Lambda. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Nome da IAM Role de execução da função Lambda. |
<!-- END_TF_DOCS -->

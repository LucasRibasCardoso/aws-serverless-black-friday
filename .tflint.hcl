config {
  # Também analisa módulos locais (infra/modules/*)
  call_module_type = "local"
}

# Regras do core do Terraform (preset "recommended" + extras úteis)
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_naming_convention" {
  enabled = true # snake_case em resources, variables, outputs...
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true # main.tf / variables.tf / outputs.tf
}

# Regras específicas da AWS (tipos inválidos, runtimes de Lambda
# depreciados, tags, etc.). Confira a última versão em:
# https://github.com/terraform-linters/tflint-ruleset-aws/releases
plugin "aws" {
  enabled = true
  version = "0.44.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

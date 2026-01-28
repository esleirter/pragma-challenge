Comandos para validor modulos
```sh
terraform init -backend=false
terraform validate
terraform fmt -recursive

tflint --init
tflint

checkov -d ./
tfsec ./
```

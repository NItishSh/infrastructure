#!/bin/bash
set -xe

terraform init
terraform fmt 
terraform validate 
terraform plan -out plan 
terraform apply plan 

# sed -i 's/\\n/\'$'\n''/g' ~/.ssh/id_rsa.pub
# sed -i 's/\\n/\'$'\n''/g' ~/.ssh/id_rsa
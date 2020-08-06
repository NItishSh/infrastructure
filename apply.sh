#!/bin/bash
set -xe

terraform init
terraform fmt 
terraform validate 
terraform plan -out plan 
terraform apply plan 

set +x
# jq '.outputs.tls_private_key.value' terraform.tfstate | sed -e 's/\\n/\'$'\n''/g' -e 's/^"//' -e 's/"$//' > ~/.ssh/id_rsa
# jq '.outputs.tls_public_key.value' terraform.tfstate | sed -e 's/\\n/\'$'\n''/g' -e 's/^"//' -e 's/"$//' > ~/.ssh/id_rsa.pub
jq '.outputs.public_ip.value' terraform.tfstate | sed -e 's/\\n/\'$'\n''/g' -e 's/^"//' -e 's/"$//'

#https://gist.github.com/grenade/6318301
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
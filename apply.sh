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
# jq '.outputs.public_ip.value' terraform.tfstate | sed -e 's/\\n/\'$'\n''/g' -e 's/^"//' -e 's/"$//'
# curl -s https://raw.githubusercontent.com/jenkinsci/jenkins/jenkins-2.19.4/core/src/main/resources/jenkins/install/platform-plugins.json | jq '.[].plugins[] | select( .suggested == true ).name' |sed -e 's/\\n/\'$'\n''/g' -e 's/^"//' -e 's/"$//'

# chmod 600 ~/.ssh/id_rsa
# chmod 644 ~/.ssh/id_rsa.pub
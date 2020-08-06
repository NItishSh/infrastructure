#!/bin/bash
set -xe

read -p "cleanup the infra? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    terraform destroy -auto-approve
fi

#!/bin/bash

# Setup backend state storage. Override defaults by setting ENV/REGION env vars ahead of calling

storage_account_name="terraformstate"

: ${TF_VAR_environment:=sandbox}
: ${TF_VAR_location:=uksouth}
: ${TF_VAR_cluster_name:=akscluster}

#echo terraform init --backend-config="environments/$env-$location.backend"

if [ ! -d ".terraform" ]; then
	terraform init -reconfigure --backend-config="storage_account_name=$storage_account_name" --backend-config="container_name=${TF_VAR_environment}" --backend-config "key=${TF_VAR_cluster_name}.aks.${TF_VAR_location}.tfstate"
fi

# pass through TF commands

terraform "$@"
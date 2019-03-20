#!/bin/bash
set -e

function check_logged_in {
  set +e
  az account show 2> /dev/null > /dev/null
  if [ $? != 0 ]; then
    echo 'You are not logged in, please use "az login"'
    exit 1
  fi
  set -e
}

function create_rand {
  if [[ $OSTYPE == 'linux-gnu' ]]; then
    md5sum <<< ${1} | cut -c1-${2}
  else
    md5 -q -s ${1} | cut -c1-${2}
  fi
}

function clean {
  echo ${1} | sed 's/[^a-zA-Z0-9]//g' 
}

function die {
  usage
  exit 1
}

function usage {
  echo "Usage: $0 [-a|-d] -c -n baseName"
  echo "  -a:  apply infra"
  echo "  -d:  destroy infra"
  echo "  -n:  base string for resource group names"
  echo "  -c:  skip interactive prompts"
}

# initialize variables
action=""
baseName=""

while getopts ":adcn:" opt; do
  case ${opt} in
    a)
      action="apply"
    ;;
    d)
     action="destroy"
    ;;
    c)
      skipPrompt="True"
    ;;
    n)
      baseName=${OPTARG}
    ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      die
    ;;
    :)
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      die
    ;;
  esac
done

if [ x"${action}" != x"apply" -a x"${action}" != x"destroy" ]; then
  echo "action has to be either -a (apply) or -d (destroy)"
  die
fi

[ -z ${baseName} ] && echo && die

if [[ ${baseName} =~ [A-Z] ]]; then
  export baseName=$(echo ${baseName} | awk '{print tolower}')
fi

check_logged_in

export random=$(create_rand ${baseName} 4)
export resourceGroup="bootstrap-${baseName}"
export tfStorageAccount="$(clean ${baseName}${random})"
export tfStorageContainer="$(clean ${baseName})"
export location="westeurope"

# Clean terraform directory
[ -d .terraform ] && rm -rf .terraform

# Check and display the current subscription
subscriptionId=$(az account list | jq -r ' .[] | select(.isDefault==true) | .id')
subscriptionName=$(az account list | jq -r ' .[] | select(.isDefault==true) | .name')
echo

# Check with the user we are in the right subscription

echo "Running in subscription: ${subscriptionName}"
echo "Subscription ID: ${subscriptionId}"

if [[ -z ${skipPrompt} ]]; then
  read -p "Are you sure? " 
  echo # (optional) move to a new line
  if [[ ! $REPLY =~ ^'yes'$ ]]; then
    [[ "$0" == "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
  fi
fi

#export servicePrincipalId="76ffeabe-a6bf-4026-b2ae-afa3dc0dc578"
#export servicePrincipalKey="zD%0ujub4%C]bxfxVsUYg4P5"
export servicePrincipalId="8b00eaeb-addd-4a90-b375-20a832b07edf"
export servicePrincipalKey="j5PLG1M:q2-?88+qds_8-yvw"
# If we are running in a CI Pipeline - set the env variables for the SP.
if [[ ${skipPrompt} ]]; then
  export ARM_CLIENT_ID=$(az keyvault secret show --vault-name "warroomkeyvault" -n sp-id | jq -r .value)
  export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name "warroomkeyvault" -n sp-key | jq -r .value)
  export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --vault-name "warroomkeyvault" -n subscription-id | jq -r .value)
  export ARM_TENANT_ID=$(az keyvault secret show --vault-name "warroomkeyvault" -n tenant-id | jq -r .value)
  az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
 fi

echo

# Check and create for resource group
if [[ $(az group show -n ${resourceGroup} -o tsv | wc -l) -eq 0 ]]; then
	echo "Creating Resource Group \"${resourceGroup}\" ..."
	az group create --name ${resourceGroup} --location ${location}
else
	echo "Resource Group \"${resourceGroup}\" already exists, nothing todo"
fi

# Check and update storage account
AccountCheck=$(az storage account check-name --name ${tfStorageAccount})
nameAvailable=$(echo ${AccountCheck} | jq -r '.nameAvailable')
reason=$(echo ${AccountCheck} | jq -r '.reason')
message=$(echo ${AccountCheck} | jq -r '.message')
if [[ "${nameAvailable}" == "true" ]]; then
	echo "Storage Account \"${tfStorageAccount}\" is missing, will be created"
	az storage account create \
		--location ${location} \
		--name ${tfStorageAccount} \
		--resource-group ${resourceGroup} \
		--sku Standard_GRS \
		--encryption-services blob \
		--kind BlobStorage \
		--access-tier hot \
		--https-only
# Output error message if the Storage Account name is not available and the reason is AccountNameInvalid
elif [[ ${nameAvailable} == "false" ]] && [[ ${reason} == "AccountNameInvalid" ]]; then 
	echo ${message}
	exit 1
else
	# Check that if the storage account exists that it exists inside the resource group we are creating.
	if [[ $(az storage account list  --resource-group ${resourceGroup} | jq -r .[].name) == "${tfStorageAccount}" ]]; then
	echo "Storage Account \"${tfStorageAccount}\" already exists in this resource group, nothing todo"
	else
	echo "Storage Account seems to already be in use, but not in this resource group."
	exit 1
	fi
fi

# Grab the storage connection string
echo "Fetching storage connection string"
AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
	--name ${tfStorageAccount} \
	--resource-group ${resourceGroup} | jq -r '.connectionString')
export AZURE_STORAGE_CONNECTION_STRING

# Use the connection string to get the account key
echo "Fetching storage key"
tfStorageKey=$(az storage account keys list \
	--account-name ${tfStorageAccount} \
	--resource-group ${resourceGroup} 2>/dev/null | jq -r .[0].value)
export tfStorageKey

# Use the connection string to check and create the storage account container
if [[ $(az storage container exists --name ${tfStorageContainer} | jq -r '.exists') == false ]]; then
	echo "Storage Container \"${tfStorageContainer}\" is missing, will be created"
	az storage container create \
		--name ${tfStorageContainer} 
else
	echo "Storage Container \"${tfStorageContainer}\" already exists, nothing todo"
fi

echo "Initialising TF Backend"
terraform init -reconfigure \
	-backend-config="container_name=${tfStorageContainer}" \
	-backend-config="storage_account_name=${tfStorageAccount}" \
	-backend-config="key=infra.${baseName}.tfstate" \
	-backend-config="access_key=${tfStorageKey}" \
	src/

echo "Starting TF Validate"
terraform validate -var "basename=${baseName}" src/

if [[ -z ${skipPrompt} ]]; then
  echo "Starting TF Apply"
  terraform ${action} -var "basename=${baseName}" src/
  else
  echo "Starting TF Apply without prompt"
  terraform ${action} -var "basename=${baseName}" -auto-approve src/ 
fi

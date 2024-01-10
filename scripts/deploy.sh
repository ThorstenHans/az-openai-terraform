#! /bin/bash

# Use this script to deploy the entire application to your Azure subscription
# After verifying that all necessary tools are installed (terraform, Azure CLI), 
# This script will do the following in sequence:

# 1. Deploy global Infrastructure (./infrastructure/global)
# 2. Build the container image for the sample app and store it in ACR
# 3. Deploy the application infrastructure (./infrastructure/workload)

# You can pass --skip-build to the script to prevent it from building the container image for 
# the sample app. In that case, the script will take the most recent tag from ACR for the sample app.

# The script cancels execution on first error
set -e

# check if terraform executable is available
if ! command -v terraform &> /dev/null
then
    echo "The HashiCorp Terraform CLI (terraform) could not be found"
    exit
fi

# check if azure cli is available
if ! command -v az &> /dev/null
then
    echo "The Azure CLI (az) could not be found"
    exit
fi

echo "Deploying global infrastructure to Azure..."

cd infrastructure
cd global

# Initialize the project, validate it and deploy it
terraform init -upgrade
terraform validate
terraform apply -auto-approve

# As the projects specifies a bunch of output variables, we grab them here
targetRgName=$(terraform output -raw resource_group_name)
targetAcrName=$(terraform output -raw acr_name)
suffix=$(terraform output -raw suffix)

echo "Created Resource Group:           $targetRgName"
echo "Created Azure Container Registry: $targetAcrName"
echo "Created Resource Suffix:          $suffix"

cd ..
cd ..
echo "✅ Global Infrastructure deployed"
read -p "Please press [ENTER] to continue..."

# fallback image tag is 0.0.1
imageTag="0.0.1"
if [ "$1" != "--skip-build" ]; then
    echo "Building and Pushing container image for sample app..."
    cd sample_app
    echo "Authenticating with ACR..."

    az acr login --name $targetAcrName
    imageTag=$(az acr build --no-logs -r $targetAcrName -t sample_app:{{.Run.ID}} . -otsv --query "runId")
    cd ..
    echo "✅ Container Image build and pushed to ACR..."
    read -p "Please press [ENTER] to continue..."
else
    echo "Skipping container image build due to --skip-build flag..."
    imageTag=$(az acr repository show-tags -n $targetAcrName --repository sample_app --orderby time_desc -otsv --query [0])
first
echo ""
echo "Using Image Tag:                   $imageTag"
echo "Deploying Workload Infrastructure to Azure..."

cd infrastructure
cd workload

# Initialize the project, validate it and deploy it
terraform init -upgrade
terraform validate
terraform apply -var resource_group_name=$targetRgName -var arc_name=$targetAcrName -var image_tag=$imageTag -var suffix=$suffix -auto-approve

echo "✅ Workload Infrastructure deployed to Azure..."
echo "✅ All Done!"

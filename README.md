# Secure deployment of GPT-4 with Azure OpenAI using Terraform

This repository contains a sample application to demonstrate secure deployment of a GPT-4 model in Azure Open AI using HashiCorp Terraform.

## Additional context

Although HTTP APIs could be protected using proper authentication patterns such as OAuth 2.0 and OIDC, additional cloud-vendor specific services should be placed in front of the Azure Container App instance used in this example. Both AuthN and first line of defense cloud services are out of scope for this example.

Also out of scope are well-known Terraform best-practices in the context of state management and authentication. Consult my blog or some of my repositories here on GitHub to spot proper examples for those kinds of things.

## Sample Application

The sample application is a fairly simple HTTP API (written in Python). The app will be hosted using Azure Container Apps. The app itself communicates with GPT-4 within the boundaries of an Azure Virtual Network (vNET).

## The Azure OpenAI instance

The Azure OpenAI service instance is integrated in a dedicated `backend` subnet and access is restricted via a Network Security Group (NSG). The NSG is configured to allow inbound traffic from the `app` subnet only.

## Infrastructure separation

I prefer splitting Terraform projects to mimic real-world processes and cloud infrastructure boundaries. Because of that, you can find two Terraform projects in the `infrastructure` folder:

1. `global`: Responsible for deploying and mutating global resources such as the Azure Container Registry (ACR). Organizations usually share a single ACR across multiple projects or environments.
2. `workload`: Responsible for deploying and mutating workload-specific resources such as the Azure Container App (ACA) instance, Virtual Network infrastructure, and Azure OpenAI Service.

## Deploying the application

I've written a small shell script (`./scripts/deploy.sh`) deploy the entire infrastructure at once. From a high level point of view the shell script does the following things in sequence:

1. Deploy (or update) the global infrastructure
2. Build the Docker image for the sample application and persist it in the ACR instance
3. Deploy (or update) the workload infrastructure

> Optionally, you can pass the `--skip-build` flag to `./scripts/deploy.sh` which will prevent the script from building a new image tag. If `--skip-build` is passed, the script will use the most recently pushed tag of the Docker image available in ACR.

! **IMPORTANT:** Both scripts `./scripts/deploy.sh` and `./scripts/get_sample_app_url.sh` are designed to be invoked from within the root folder of this repository.

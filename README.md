# Deploy-Web-Server-In-Azure

# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure
 
# 
### Introduction
This project is to creating infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
 
To deploy the scalable web server in Azure we need:

1. Deploy a Policy

Create a Azure policy by using the following command in the terminal: 

		az policy definition create --name tagging-policy --mode indexed --rules tagging-policy.json --params paras.json

 

Assign policy by : 

		az policy assignment create --name tagging-policy-assignment --policy tagging-policy --params "{ \"tagName\": {\"value\": \"udacity\"} }"

 

2. Delpoy a Packer image by Terraform

   Create resource group to store Packer Image By:

   		az group create -l eastus -n packerImageResourceGroup

   Create an azure service principal to use terraform with the following command by:


    	az ad sp create-for-rbac --role="Contributor"
    	az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"

    	export ARM_SUBSCRIPTION_ID="90447603-4de8-44b6-8de6-9f5aff4ae738"
		export ARM_CLIENT_ID="eb01e622-3d71-4fd4-bc06-75ff5e5dd8f0"
		export ARM_CLIENT_SECRET="xtQ5qoc.mApnYp7u2TnQ3vDQorpGay.zq1"
		export ARM_TENANT_ID="94b6094f-f2a4-4928-8070-5893ca9078cd"



    Copy the from outputs 5 values: appId, displayName, name, password, and tenant.
    Export the environment variables add set your client_id, client_secret, and subscription_id as environment variablesinto the Packer template file server.json

   
   Create and deploy your vm machine image to Azure using Packer by: 

   packer build server.json


3. Deploy Azure resources with Terraform
	
	terraform init
  
	terraform plan -out solution.plan
  
	terraform apply "solution.plan"


4. Destroy the resources

	terraform destroy
	
	Destroy image built by Packer 

	az group delete --name packerImageResourceGroup --yes
	az image delete -g packerImageResourceGroup -n packer-image
	az group delete --name udacity-rg  --yes

	




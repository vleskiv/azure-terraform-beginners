# azure-terraform
Beginners Guide to Terraforming Azure

# Authentication
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az account list
# az account set -s <Subscription ID>
# az vm list-skus --location centralus --size Standard_A --output table
```

# Usage
```bash
export MY_PREFIX="tfguide"
terraform init
terraform apply \
	-var="prefix=$MY_PREFIX" \
	-var="vm_size=Standard_B1s" \
	-var="admin_password=My-long-pwd"
terraform destroy -auto-approve
```
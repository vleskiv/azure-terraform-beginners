# azure-terraform
Beginners Guide to Terraforming Azure

# Required terraform version: 11 

# Authentication
```bash
# Install azure-cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# Authorize azure-cli using your account
az login 
# Set the subscription
az account set --subscription <subscription name>
# Check that "isDefault": true corresponds to the subscription above
az account list
# List available SKU's
# az vm list-skus --location centralus --size Standard_A --output table
```

# Usage (flat file)
```bash
terraform init
# Module documentation: .terraform\modules\<random_id>\Azure-terraform-azurerm-compute-5b4096c\README.md

terraform plan \
        -var="prefix=<YOUR_UNIQUE_SLB_USERNAME>" \
	-var="vm_size=Standard_B1s" \
	-var="admin_password=My-long-pwd"

terraform apply \
        -var="prefix=<YOUR_UNIQUE_SLB_USERNAME>" \
	-var="vm_size=Standard_B1s" \
	-var="admin_password=My-long-pwd"

terraform destroy
```

# Usage (flat file + module)
- Rename `module.tf.disabled` > `module.tf`
- Check that you have default ssh key:
for linux `~/.ssh/id_rsa.pub`.
for windows `C:\Users\%USER%/.ssh/id_rsa.`
If not - generate it:
```
ssh-keygen -t rsa -b 4096 -C username@example.com
```
- To use terraform 12 remove (or comment) variable `version` in module `linuxserver` that is hardcoded for compatibility with terraform 11.
- Apply terraform: see previous step "Usage (flat file)"

# Issues
## 1) Can't output public dynamic IP
```
        * module.linuxserver.output.public_ip_address: Resource 'azurerm_public_ip.vm' does not have attribute 'ip_address' for variable 'azurerm_public_ip.vm.*.ip_address'
```
Only static IP address is able to be written to the output, but not dynamic one
- For terraform 11 you can avoid the error by setting environment variable TF_WARN_OUTPUT_ERRORS=1
- Change "public_ip_address_allocation" from "dynamic" to "static"
## 2) The requested size is not available in location
```
Error: Error applying plan:
2 errors occurred:
        * azurerm_virtual_machine.site: 1 error occurred:
        * azurerm_virtual_machine.site: compute.VirtualMachinesClient#CreateOrUpdate: Failure responding to request: StatusCode=409 -- Original Error: autorest/azure: Service returned an error. Status=409 Code="SkuNotAvailable" Message="The requested size for resource '/subscriptions/9015a40c-7415-4779-ba69-4e1465441aca/resourceGroups/tfguide-Terraform-Azure-Beginners/providers/Microsoft.Compute/virtualMachines/catapp-site' is currently not available in location 'centralus' zones '' for subscription '9015a40c-7415-4779-ba69-4e1465441aca'. Please try another size or deploy to a different location or zones. See https://aka.ms/azureskunotavailable for details."
```
Not all VM sizes are available in some locations/zones
- List available VM sizes `az vm list-skus --location centralus --size Standard_A --output table`
## 3) Module can't find required file
```
Error: module.linuxserver.azurerm_virtual_machine.vm-linux: 1 error occurred:
        * module.linuxserver.azurerm_virtual_machine.vm-linux: file: open : no such file or directory in:
${file("${var.ssh_key}")}
```
- Create file or specify another path in variable
## 4) DNS record *.cloudapp.azure.com is already used by another public IP
```
Error: Error applying plan:
2 errors occurred:
        * module.linuxserver.azurerm_public_ip.vm: 1 error occurred:
        * azurerm_public_ip.vm: network.PublicIPAddressesClient#CreateOrUpdate: Failure responding to request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="DnsRecordInUse" Message="DNS record linsimplevmips.westus2.cloudapp.azure.com is already used by another public IP." 
```
- Specify globally unique name in variable
- Using `random` function add autogenerated suffix at the end of string
## 5) Error during terraform init using modules from terraform repository
Terraform repo provides different versions of modules and providers. Usually, the latest versions work only with terraform v12. 
If you have an existing script for v11 and you want to add module - you have to specify an older version of module or provider that supports v11.
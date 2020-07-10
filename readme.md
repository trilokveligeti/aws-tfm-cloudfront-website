# AWS CloudFront Demo
This a simplified demo showing how to deploy and host a static website on AWS.

## The Demo Application
The demo application can be any static website. Works great with SPA frameworks. This has been tested with ReactJS and Angular apps.

## Tools
Only [Terraform](https://www.terraform.io/) is used in this demo. 

## Structure
The folder structure looks like this

```
+-- main.tf
+-- variables.tf
+-- outputs.tf
+-- _ modules 
|   +-- custom-module-folder (custom module to something cool)
|       +-- main.tf
|       +-- vars.tf
|       +-- outputs.tf
+-- _ secrets (store stuff you dont want to checkin)
|   +-- secret-vars.tf

```

## Usage

### `terraform init`

Initializes the terraform project.<br />
Downloads the required plugins.

### `terraform plan`

Runs the validation for the execution plan. Displays any changes/updates.

### `terraform apply`

Deploys the infrstructure. Will use the `variables.tf` for variable definitions. 

To include additional variabes from secrets folder, use the command with `-var-file=""` option.

```
terraform apply -var-file=secrets/auth-secrets.tfvars 
```



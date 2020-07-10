# AWS CloudFront Demo
This a simplified demo showing how to deploy and host a static website on AWS.

## The Demo Application
The demo application can be any static website. Works great with SPA frameworks. This has been tested with ReactJS and Angular apps.
I have used [React Todo](https://github.com/trilokveligeti/react-todo) as the application to build and deploy

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
|       +-- misc.tf
|       +-- outputs.tf
+-- _ secrets (store stuff you dont want to checkin)
|   +-- secret-vars.tfvars

```

## Usage

### `terraform init`

Initializes the terraform project.<br />
Downloads the required plugins.

### `terraform plan`

Runs the validation for the execution plan. Displays any changes/updates.

### `terraform apply`

Deploys the infrstructure. Will use the `variables.tf` for variable definitions. 

To include additional variabes from secrets folder, use the command with `-var-file=some-secret-information.tfvars` option.

```
terraform apply -var-file=secrets/auth-secrets.tfvars 
```

## Gotchas
### S3 uploads with default content-type
When using the `aws_s3_bucket_object` to upload files to S3, the files are uplaoded with content-type as  binary/octet-stream
To work around this issue, I have defined the mapping based on the file extensions in variables.tf

```
  content_type = "${lookup(var.content_types, element(split(".", each.value) , length(split(".", each.value)) - 1), "binary/octet-stream")}"

```

Another option would be to use local provisioner and execute s3 uploads with AWS CLI



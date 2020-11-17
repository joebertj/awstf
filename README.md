# awstf
A module-base terraform for aws

## setting up the terraform backend 
This is used to generate the needed S3 and DynamoDB for Terraform state and locks.
```
cd backend
terraform workspace new backend
terraform init
terraform plan
terraform apply
cd ..
terraform workspace select default
```

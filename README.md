# AWS S3 Logging Bucket

This terraform module provisions an AWS S3 bucket suitable for storing logs from AWS services. 

The module creates a private bucket with limited access. Only read permissions are granted on the bucket.

The bucket is encrypted using SSE-S3.

The following services are supported:

* Application Load Balancers
* CloudFront
* S3
* VPC Flows

## Example

To configure the module using sane defaults, add the following snippet to your project.

```hcl2
module "logging_bucket" {
  source = "git@github.com:org/terraform-aws-module-s3-logging?ref=main"

  prefix = "myco" # Use your standard S3 namespace prefix
  tags   = var.tags
}
```

For more complex environments, you may want to split your logging buckets out by type. Here is an example of doing that for CloudFront and VPC flow logs:

```hcl2
module "logging_bucket_cloudfront" {
  source = "git@github.com:org/terraform-aws-module-s3-logging?ref=main"

  prefix = "myco"
  suffix = "cloudfront"
  tags   = var.tags

  services = {
    alb = false
    s3  = false
    vpc = false
  }
}

module "logging_bucket_vpc" {
  source = "git@github.com:org/terraform-aws-module-s3-logging?ref=main"

  prefix = "myco"
  suffix = "vpc"
  tags   = var.tags

  services = {
    alb        = false
    cloudfront = false
    s3         = false
  }
}
```

## Generated Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0, <2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The namesapce prefix to prepend to the bucket name. This should be standard for all buckets | `string` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | A list of services to allow to log to the bucket. Defaults to all supported services | <pre>object({<br/>    alb        = optional(bool, true)<br/>    cloudfront = optional(bool, true)<br/>    s3         = optional(bool, true)<br/>    vpc        = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Suffix to append to the bucket name. Only required if not all services are enabled | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the S3 bucket |
<!-- END_TF_DOCS -->
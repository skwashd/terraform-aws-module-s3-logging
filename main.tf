data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

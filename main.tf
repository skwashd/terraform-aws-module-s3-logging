data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_region" "current" {}

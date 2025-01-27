variable "prefix" {
  description = "The namesapce prefix to prepend to the bucket name. This should be standard for all buckets"
  type        = string

  validation {
    condition     = length(var.prefix) >= 3
    error_message = "The prefix must be at least 3 characters long"
  }

  validation {
    condition     = length(var.prefix) <= 10
    error_message = "The prefix length must not exceed 10 characters"
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.prefix))
    error_message = "The prefix must contain only lowercase letters and numbers"
  }
}

variable "services" {
  description = "A list of services to allow to log to the bucket. Defaults to all supported services"
  type = object({
    alb        = optional(bool, true)
    cloudfront = optional(bool, true)
    s3         = optional(bool, true)
    vpc        = optional(bool, true)
  })

  default = {}
}

variable "suffix" {
  description = "Suffix to append to the bucket name. Only required if not all services are enabled"
  type        = string
  default     = ""

  validation {
    condition     = length(var.suffix) <= 10
    error_message = "The suffix length must not exceed 10 characters"
  }

  validation {
    condition     = !(!alltrue([for k, v in var.services : v]) && var.suffix == "")
    error_message = "The suffix is required unless all services are enabled"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

locals {
  bucket_name = var.suffix != "" ? "${var.prefix}-${data.aws_caller_identity.current.account_id}-logs-${var.suffix}" : "${var.prefix}-${data.aws_caller_identity.current.account_id}-logs-common"
}

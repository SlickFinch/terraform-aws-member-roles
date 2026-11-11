variable "name" {
  description = "Name of the StackSet."
  type        = string
}

variable "description" {
  description = "Description of the StackSet."
  type        = string
  default     = "IAM role in member accounts."
}

variable "role_name" {
  description = "Name of the IAM role created in every member account."
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role."
  type        = string
  default     = "Role deployed to member accounts by a StackSet."
}

variable "template_description" {
  description = "Description of the CloudFormation template."
  type        = string
  default     = "IAM role for member accounts."
}

variable "trusted_role_arns" {
  description = "IAM role ARNs that may assume the role (sts:AssumeRole and sts:TagSession)."
  type        = list(string)

  validation {
    condition     = length(var.trusted_role_arns) > 0 && alltrue([for arn in var.trusted_role_arns : can(regex("^arn:aws:iam::\\d{12}:role/", arn))])
    error_message = "trusted_role_arns must list at least one IAM role ARN."
  }
}

variable "managed_policy_arns" {
  description = "Managed policy ARNs attached to the role."
  type        = list(string)

  validation {
    condition     = length(var.managed_policy_arns) > 0
    error_message = "managed_policy_arns must list at least one policy."
  }
}

variable "organizational_unit_ids" {
  description = "OUs to deploy to. Accounts in child OUs are included, and accounts that join later get the role automatically."
  type        = list(string)

  validation {
    condition     = length(var.organizational_unit_ids) > 0 && alltrue([for id in var.organizational_unit_ids : can(regex("^(ou-[0-9a-z]{4,32}-[0-9a-z]{8,32}|r-[0-9a-z]{4,32})$", id))])
    error_message = "organizational_unit_ids must list OU IDs (ou-...) or the root ID (r-...)."
  }
}

variable "region" {
  description = "The one Region the stacks deploy to. IAM is global, so one is enough; changing it recreates the role in every account."
  type        = string
}

variable "retain_stacks_on_account_removal" {
  description = "Keep the role in an account that leaves the OUs. The default removes it, so no access stays in accounts you no longer manage."
  type        = bool
  default     = false
}

variable "max_concurrent_count" {
  description = "Accounts deployed at the same time."
  type        = number
  default     = 4
}

variable "failure_tolerance_count" {
  description = "Account failures allowed before the operation stops."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags for the StackSet."
  type        = map(string)
  default     = {}
}

variable "logical_id" {
  description = "CloudFormation logical ID of the role. Never change it once deployed: a new ID replaces the role in every account."
  type        = string
  default     = "Role"
}

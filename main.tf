resource "aws_cloudformation_stack_set" "this" {
  name             = var.name
  description      = var.description
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = var.retain_stacks_on_account_removal
  }

  managed_execution {
    active = true
  }

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = var.template_description
    Resources = {
      (var.logical_id) = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName    = var.role_name
          Description = var.role_description
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [{
              Sid       = "TrustedRoles"
              Effect    = "Allow"
              Principal = { AWS = var.trusted_role_arns }
              Action    = ["sts:AssumeRole", "sts:TagSession"]
            }]
          }
          ManagedPolicyArns = var.managed_policy_arns
        }
      }
    }
  })

  tags = var.tags

  lifecycle {
    # AWS fills this in for SERVICE_MANAGED StackSets, which would show as a change on every plan.
    ignore_changes = [administration_role_arn]
  }
}

resource "aws_cloudformation_stack_set_instance" "this" {
  stack_set_name            = aws_cloudformation_stack_set.this.name
  stack_set_instance_region = var.region

  deployment_targets {
    organizational_unit_ids = var.organizational_unit_ids
  }

  operation_preferences {
    concurrency_mode        = "SOFT_FAILURE_TOLERANCE"
    failure_tolerance_count = var.failure_tolerance_count
    max_concurrent_count    = var.max_concurrent_count
  }
}

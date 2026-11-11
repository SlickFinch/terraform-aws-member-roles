# Runs without AWS credentials: `tofu test` (or `terraform test`).

mock_provider "aws" {}

variables {
  name                    = "example-member-ci-role"
  role_name               = "ExampleCIRole"
  trusted_role_arns       = ["arn:aws:iam::111111111111:role/ExampleCIRole"]
  managed_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  organizational_unit_ids = ["ou-abcd-12345678"]
  region                  = "us-west-2"
}

run "service_managed_with_auto_deployment" {
  command = plan

  assert {
    condition     = aws_cloudformation_stack_set.this.permission_model == "SERVICE_MANAGED"
    error_message = "The StackSet must be service-managed."
  }

  assert {
    condition     = aws_cloudformation_stack_set.this.auto_deployment[0].enabled == true
    error_message = "Accounts that join the OUs later must get the role."
  }

  assert {
    condition     = aws_cloudformation_stack_set.this.auto_deployment[0].retain_stacks_on_account_removal == false
    error_message = "By default an account that leaves the OUs must lose the role."
  }
}

run "template_trusts_only_the_given_roles" {
  command = plan

  assert {
    condition     = jsondecode(aws_cloudformation_stack_set.this.template_body).Resources.Role.Properties.AssumeRolePolicyDocument.Statement[0].Principal.AWS == ["arn:aws:iam::111111111111:role/ExampleCIRole"]
    error_message = "The role must trust only trusted_role_arns."
  }

  assert {
    condition     = jsondecode(aws_cloudformation_stack_set.this.template_body).Resources.Role.Properties.RoleName == "ExampleCIRole"
    error_message = "The role must use role_name."
  }
}

run "logical_id_is_configurable" {
  command = plan

  variables {
    logical_id = "DiggerRole"
  }

  assert {
    condition     = keys(jsondecode(aws_cloudformation_stack_set.this.template_body).Resources) == ["DiggerRole"]
    error_message = "The template must use logical_id."
  }
}

run "deploys_to_the_given_ous" {
  command = plan

  assert {
    condition     = aws_cloudformation_stack_set_instance.this.deployment_targets[0].organizational_unit_ids == toset(["ou-abcd-12345678"])
    error_message = "The instance must target organizational_unit_ids."
  }

  assert {
    condition     = aws_cloudformation_stack_set_instance.this.stack_set_instance_region == "us-west-2"
    error_message = "The instance must deploy to region."
  }
}

run "rejects_user_arn" {
  command = plan

  variables {
    trusted_role_arns = ["arn:aws:iam::111111111111:user/someone"]
  }

  expect_failures = [var.trusted_role_arns]
}

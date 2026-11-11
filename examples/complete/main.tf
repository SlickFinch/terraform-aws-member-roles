# Run in the management account (or a delegated StackSets administrator).
provider "aws" {
  region = "us-west-2"
}

module "member_ci_role" {
  source = "../.."

  name                    = "acme-member-ci-role"
  role_name               = "AcmeCIRole"
  role_description        = "CI plan and apply, assumed from the management account."
  trusted_role_arns       = ["arn:aws:iam::111111111111:role/AcmeCIRole"]
  managed_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  organizational_unit_ids = ["ou-abcd-12345678", "ou-abcd-87654321"]
  region                  = "us-west-2"
}

output "stack_set_name" {
  description = "Name of the StackSet."
  value       = module.member_ci_role.stack_set_name
}

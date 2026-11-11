# terraform-aws-member-roles

OpenTofu and Terraform module that puts one IAM role in every member account of the chosen OUs, through a service-managed CloudFormation StackSet. Accounts that join the OUs later get the role automatically. By default, an account that leaves the OUs loses it.

The usual use is a CI role, for example the role a Digger or GitHub Actions role in the management account assumes in each member account.

## Usage

Run it in the management account (or a delegated StackSets administrator). The Organization needs trusted access for `member.org.stacksets.cloudformation.amazonaws.com`. Pin the module to a release tag:

```hcl
module "member_ci_role" {
  source = "git::https://github.com/SlickFinch/terraform-aws-member-roles.git?ref=v1.0.0"

  name                    = "acme-member-ci-role"
  role_name               = "AcmeCIRole"
  trusted_role_arns       = ["arn:aws:iam::111111111111:role/AcmeCIRole"]
  managed_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  organizational_unit_ids = ["ou-abcd-12345678"]
  region                  = "us-west-2"
}
```

See [examples/complete](examples/complete).

## Things that replace the role everywhere

- Changing `region` moves every stack to the new Region.
- Changing `logical_id` gives CloudFormation a new resource, so it deletes the old role and creates a new one.

## Testing

`tofu test` runs the tests in `tests/` with a mocked AWS provider, so it needs no credentials.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudformation_stack_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | Managed policy ARNs attached to the role. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the StackSet. | `string` | n/a | yes |
| <a name="input_organizational_unit_ids"></a> [organizational\_unit\_ids](#input\_organizational\_unit\_ids) | OUs to deploy to. Accounts in child OUs are included, and accounts that join later get the role automatically. | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The one Region the stacks deploy to. IAM is global, so one is enough; changing it recreates the role in every account. | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role created in every member account. | `string` | n/a | yes |
| <a name="input_trusted_role_arns"></a> [trusted\_role\_arns](#input\_trusted\_role\_arns) | IAM role ARNs that may assume the role (sts:AssumeRole and sts:TagSession). | `list(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the StackSet. | `string` | `"IAM role in member accounts."` | no |
| <a name="input_failure_tolerance_count"></a> [failure\_tolerance\_count](#input\_failure\_tolerance\_count) | Account failures allowed before the operation stops. | `number` | `0` | no |
| <a name="input_logical_id"></a> [logical\_id](#input\_logical\_id) | CloudFormation logical ID of the role. Never change it once deployed: a new ID replaces the role in every account. | `string` | `"Role"` | no |
| <a name="input_max_concurrent_count"></a> [max\_concurrent\_count](#input\_max\_concurrent\_count) | Accounts deployed at the same time. | `number` | `4` | no |
| <a name="input_retain_stacks_on_account_removal"></a> [retain\_stacks\_on\_account\_removal](#input\_retain\_stacks\_on\_account\_removal) | Keep the role in an account that leaves the OUs. The default removes it, so no access stays in accounts you no longer manage. | `bool` | `false` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description of the IAM role. | `string` | `"Role deployed to member accounts by a StackSet."` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the StackSet. | `map(string)` | `{}` | no |
| <a name="input_template_description"></a> [template\_description](#input\_template\_description) | Description of the CloudFormation template. | `string` | `"IAM role for member accounts."` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role in every member account. |
| <a name="output_stack_set_id"></a> [stack\_set\_id](#output\_stack\_set\_id) | ID of the StackSet. |
| <a name="output_stack_set_name"></a> [stack\_set\_name](#output\_stack\_set\_name) | Name of the StackSet. |
<!-- END_TF_DOCS -->

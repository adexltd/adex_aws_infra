# AWS Application Load Balancer Terraform Module
Terraform module which creates Application Load Balancer resources on AWS.

## ALB configuration rules:

1. Redirect HTTP to HTTPS
2. Forward to target group based on below HTTP header and Path condition,the `gateway_key` header is passed from api gateway to routes starting with `api`, this restricts usage of API's only from APIGW
    - Forward  traffic which matches HTTP `header` : `gateway_key` (one or more comparison strings) to respective path.
    - Forward traffic containing path `*/api/* OR */api/v2/ OR */api*` to corresponding target group
3. Forward all traffic containing path `/media/* OR /static/* OR */media/* OR */admin*` to corresponding target group, this ensures admin and static files to be accessed from ALB.
4. All other routes will return fixed response of status code `500`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.56.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.56.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.alb](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/alb) | resource |
| [aws_alb_listener.alb_http](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/alb_listener) | resource |
| [aws_alb_listener.alb_https](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/alb_listener) | resource |
| [aws_alb_listener_rule.api_rule](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/alb_listener_rule) | resource |
| [aws_alb_listener_rule.listener_rule](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/alb_listener_rule) | resource |
| [aws_alb_target_group.tg](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/alb_target_group) | resource |
| [aws_security_group.alb_security_group](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_security_group_egress](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.alb_security_group_http](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.alb_security_group_https](https://registry.terraform.io/providers/hashicorp/aws/3.56.0/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
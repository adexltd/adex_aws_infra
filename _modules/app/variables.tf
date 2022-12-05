# Global
variable "env" {
  type        = string
  default     = "dev"
  description = "Environment to which it runs"
}
variable "tags"{
    type    = string
    description = "Tags to know additional details"
}
variable "ami_id" {
  type        = string
  default     = null
  description = " AMI ID to deploy in us-east-1 region"
}
variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}
variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.medium"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "public_subnets" {
  type        = list(any)
  description = "List of public subnet id's where load balancer can be launched"
}
variable "private_subnets" {
  type        = list(any)
  description = "List of private subnet id's where ec2 can be launched"
}
variable "load_balancer_certificate" {
  type        = string
  description = "ACM certificate to be attached to ALB"
}
variable "gateway_key" {
  type        = string
  description = "Static gateway key for private communication between APIGW and LoadBalancer"
}
variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone id"
  default     = null
}

variable "alb_record_name" {
  type        = string
  description = "ALB record name to be attached to ALB"
  default     = null
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "env_overrides" {
  type        = map(string)
  description = "ENV value to override"
}
#ASG
variable "min_size" {
  type        = number
  description = "Min no of instances to serve traffic"
  default     = 1
}
variable "max_size" {
  type        = number
  description = "Max no of instances to serve traffic"
  default     = 1
}
variable "desired_capacity" {
  type        = number
  description = "Desired no of instances to serve traffic"
  default     = 1
}
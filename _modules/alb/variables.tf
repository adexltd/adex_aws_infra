
variable "vpc_id" {

}

variable "subnet_ids" {
  type = list(string)
}

variable "name" {

}

variable "certificate_arn" {
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


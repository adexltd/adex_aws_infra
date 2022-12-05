variable "ami_id" {

}

variable "vpc_id" {

}

variable "subnet_id" {

}

variable "name" {

}

variable "instance_type" {

}
variable "key_name" {

}

variable "ebs_volume_size" {
  default = 25
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

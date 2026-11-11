variable "name" {
  type        = string
  description = "Name prefix; also becomes the private DNS domain (<name>.internal)."
}

variable "vpc_id" {
  type        = string
  description = "VPC the private DNS namespace is attached to."
}

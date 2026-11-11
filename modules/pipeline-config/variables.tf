variable "name" {
  type        = string
  description = "Name prefix; parameters are created under /<name>/."
}

variable "values" {
  type        = map(string)
  description = "Parameter name (without prefix) to value."
}

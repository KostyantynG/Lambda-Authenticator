variable "account_id" {
  description = "AWS account id to deploy infrastructure to"
  type = string
}

variable "region" {
  description = "The region to deploy the infrastructure to"
  type        = string
}

variable "env" {
  type        = string
  description = "Deployment environment i.e. dev, qa, prod, test"
}

variable "name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all taggable resources"
  type        = map(string)
}

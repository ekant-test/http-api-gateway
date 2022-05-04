# --- network configuration of the account ------------------------------------

variable "vpc_id" {
  type        = string
  description = "The VPC id into which to place the ALB."
  default = "vpc-******"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The list of subnet ids into which to place the AWS API gateway VPC Link."
  default = ["subnet-******", "subnet-******"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The list of subnet ids into which to place the load balancer."
  default = ["subnet-******", "subnet-*******"]
}

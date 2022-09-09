variable "access_key" {}
variable "secret_key" {}

variable "region" {}
variable "ecs-cluster-1" {}

variable "ecs_security_groups" {
  default = ["sg-0ca04f8187695ff21"]
}

variable "capacity" {
  default = 2
}
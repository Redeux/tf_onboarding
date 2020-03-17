variable "AWS_REGION" {
  type    = string
  default = "us-east-2"
}

variable "INSTANCE_COUNT" {
    type = number
    default = 1
}

variable "AWS_INSTANCE_TYPE" {
  type    = string
  default = "t2.nano"
}
/*
variable "TAG_USER_NAME" {
  type = string
}
*/
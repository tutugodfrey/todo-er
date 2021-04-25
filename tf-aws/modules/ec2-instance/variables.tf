variable "profile" {
  default = "tgodfrey"
}
variable "region" {
  default = "us-west-2"
}
variable "ami_id" {
  default = "ami-0e999cbd62129e3b1"
}
variable "ec2_keypair" {
  default = "aws2-oregon-key"
}
variable "ec2_instance_type" {
  default = "t2.micro"
}
variable "subnet_id" {}
variable "private_ip" {}
variable "security_groups" {}
variable "userdata_file" {}
variable "associate_public_ip_address" {
  default  = true
}
variable "instance_name_tag" {}
variable template_file_vars {}

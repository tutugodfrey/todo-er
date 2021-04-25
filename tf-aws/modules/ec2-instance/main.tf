data "template_file" "userdata-template-file" {
  template = file(var.userdata_file)
  vars = var.template_file_vars
}

resource "aws_instance" "ec2-instance" {
  ami = var.ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = var.security_groups
  subnet_id = var.subnet_id
  user_data = data.template_file.userdata-template-file.rendered
  associate_public_ip_address = var.associate_public_ip_address
  private_ip = var.private_ip
  tags = {
    Name = var.instance_name_tag
  }
}

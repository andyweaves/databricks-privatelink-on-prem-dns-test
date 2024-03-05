data "aws_ami" "windows" {
     most_recent = true   
     filter {
       name   = "name"
       values = ["Windows_Server-2022-English-Full-Base-*"]  
  }  
  filter {
       name   = "virtualization-type"
       values = ["hvm"]  
  }     
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "windows_vm_frontend" {
    ami = data.aws_ami.windows.id
    instance_type = "t2.medium"
    key_name = var.ec2_keypair_name
    vpc_security_group_ids = [aws_security_group.frontend.id]
    associate_public_ip_address = true
    subnet_id = module.vpc.public_subnets[0]
    tags = {
        Name = "${var.resource_prefix}-${var.region}-windows-vm-frontend"
    }
}

resource "aws_instance" "linux_vm_dns" {
    ami = data.aws_ami.linux.id
    instance_type = "t3.medium"
    key_name = var.ec2_keypair_name
    vpc_security_group_ids = [aws_security_group.frontend.id]
    associate_public_ip_address = false
    subnet_id = module.vpc.private_subnets[0]
    tags = {
        Name = "${var.resource_prefix}-${var.region}-linux-vm-dns"
    }
}
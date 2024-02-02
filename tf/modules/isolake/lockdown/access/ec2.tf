resource "aws_instance" "windows_vm_frontend" {
    ami = "ami-0ced908879ca69797"
    instance_type = "m5d.large"
    key_name = var.ec2_keypair_name
    vpc_security_group_ids = [aws_security_group.frontend.id]
    associate_public_ip_address = true
    subnet_id = module.vpc.public_subnets[0]
    tags = {
        Name = "${var.resource_prefix}-${var.region}-windows-vm-frontend"
    }
}

resource "aws_instance" "linux_vm_frontend" {
    ami = "ami-09024b009ae9e7adf"
    instance_type = "t2.micro"
    key_name = var.ec2_keypair_name
    vpc_security_group_ids = [aws_security_group.frontend.id]
    associate_public_ip_address = true
    subnet_id = module.vpc.public_subnets[0]
    tags = {
        Name = "${var.resource_prefix}-${var.region}-linux-vm-frontend"
    }
}

# resource "aws_instance" "linux_vm_transit" {
#     ami = "ami-09024b009ae9e7adf"
#     instance_type = "t2.micro"
#     key_name = "aweaver-eu-central-1"
#     vpc_security_group_ids = [aws_security_group.transit.id]
#     subnet_id = module.transit_vpc.private_subnets[0]
#     tags = {
#         Name = "${var.resource_prefix}-${var.region}-linux-vm-transit"
#     }
# }
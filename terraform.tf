provider "aws" {
  access_key = "AKIA43DI7ZCWSFXTXTHL"
  secret_key = "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"
  region     = "us-east-2"
}
resource "aws_vpc" "Ejust-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Ejust-vpc"
  }
}
resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.Ejust-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private_1"
  }
}
resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.Ejust-vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private_2"
  }
}
resource "aws_subnet" "private_3" {
  vpc_id     = aws_vpc.Ejust-vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "private_3"
  }
}
resource "aws_security_group" "Ejust-VM-SG" {
   name        = "Ejust-VM-SG"
   description = "VM security group"
   vpc_id="Ejust-vpc"

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
// To Allow HTTPS Transport
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "Ejust-VM1" {
  ami = "ami-08b6f2a5c291246a0"
 availability_zone = "us-west-2a"
  instance_type = "t2.micro"
  security_groups = ["Ejust-VM-SG"]
  subnet_id= "private_1"
 vpc_id="Ejust-vpc"
}
resource "aws_instance" "Ejust-VM2" {
  ami = "ami-08b6f2a5c291246a0"
 availability_zone = "us-west-2a"
  instance_type = "t2.micro"
  security_groups = ["Ejust-VM-SG"]
subnet_id= "private_2"
vpc_id="Ejust-vpc"
}
resource "aws_instance" "Ejust-VM3" {
  ami = "ami-08b6f2a5c291246a0"
 availability_zone = "us-west-2a"
  instance_type = "t2.micro"
  security_groups = ["Ejust-VM-SG"]
subnet_id= "private_3"
vpc_id="Ejust-vpc"
}
resource "aws_ebs_volume" "EBS1" {
	  availability_zone = "us-west-2a"
	  size = 20  
          volume_type = "gp2"
	}

resource "aws_ebs_volume" "EBS2" {
	  availability_zone = "us-west-2a"
	  size = 20  
          volume_type = "gp2"
	}
resource "aws_ebs_volume" "EBS3" {
	  availability_zone = "us-west-2a"
	  size = 20 
          volume_type = "gp2"
	}
resource "aws_volume_attachment" "ebs_att1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.EBS1.id
  instance_id = aws_instance.Ejust-VM1.id
}
resource "aws_volume_attachment" "ebs_att2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.EBS2.id
  instance_id = aws_instance.Ejust-VM2.id
}
resource "aws_volume_attachment" "ebs_att3" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.EBS3.id
  instance_id = aws_instance.Ejust-VM3.id
}

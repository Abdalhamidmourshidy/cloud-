provider "aws" {
  
  region     = "us-east-2"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
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
 vpc_id      = "${aws_vpc.Ejust-vpc.id}"

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
    protocol = "tcp"
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
 availability_zone = "us-east-2a"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
vpc_security_group_ids = [ aws_security_group.Ejust-VM-SG.id ]
  subnet_id = aws_subnet.private_1.id

}
resource "aws_instance" "Ejust-VM2" {
 availability_zone = "us-east-2b"
   ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.Ejust-VM-SG.id ]
subnet_id = aws_subnet.private_2.id

}
resource "aws_instance" "Ejust-VM3" {
  ami = data.aws_ami.ubuntu.id
  availability_zone = "us-east-2b"
  instance_type = "t2.micro"
 vpc_security_group_ids = [ aws_security_group.Ejust-VM-SG.id ]
subnet_id = aws_subnet.private_3.id

}
resource "aws_ebs_volume" "EBS1" {
	  availability_zone = "us-east-2a"
	  size = 20  
	}

resource "aws_ebs_volume" "EBS2" {
	  availability_zone = "us-east-2b"
	  size = 20  

	}
resource "aws_ebs_volume" "EBS3" {
	  availability_zone = "us-east-2b"
	  size = 20 
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
resource "aws_launch_template" "ejustlt" {
  name_prefix   = "ejustlt"
  image_id      = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
}
resource "aws_autoscaling_group" "Ejust-ASG" {
  availability_zones        = ["us-east-2a"]
  name                      = "Ejust-ASG"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
launch_template {
    id      = aws_launch_template.ejustlt.id
    version = "$Latest"
  }
  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]
}




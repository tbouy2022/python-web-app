data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "flask-app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  availability_zone = "eu-west-2a"
  subnet_id = aws_subnet.public-sub.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  key_name = aws_key_pair.deployer.key_name

#### 

  
 #user data srcipt to configure docker
user_data = <<-EOF
            #!/bin/bash
            apt update -y
            apt install -y docker.io unzip curl
            systemctl start docker
            systemctl enable docker
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            ./aws/install
EOF    
   tags = {
    Name = "flask-app"
   }  
}
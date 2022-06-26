data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}


resource "aws_instance" "assignment2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"

  root_block_device {
    volume_size = 16
  }

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo yum install docker -y
    sudo systemctl start docker
    sudo usermod -a -G docker ec2-user
    curl -sLo kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
    sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
    rm -f ./kind
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f ./kubectl
    kind create cluster --config kind.yaml​
  EOF

  vpc_security_group_ids = [
    module.ec2_sg.security_group_id,
    module.dev_ssh_sg.security_group_id
  ]
  iam_instance_profile = "LabInstanceProfile"

  tags = {
    project = "clo835-assignment2"
  }

  key_name                = "lab2"
  monitoring              = true
  disable_api_termination = false
  ebs_optimized           = true
}

resource "aws_key_pair" "lab2" {
  key_name   = "lab2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCk55tVe+A+PruI60FKKp6d4OeD55VV7GHGWolcPx5avjVRlYeRL6Itu8kJ0K9cvu/OfgwjWjuAACkhSS3afscRlsMBpdoHjMiqicG5oBqIuuzry7nl+mqIZhQ8vfV16Dp3KPqQB3R1eO/z8jA3h6xmiYHPwBoTngMFCMyPIC+FGKmSZo+ixEXwhJskm13G0nu+UzN7U+7feNPni/3Pn4LnCb+AwfpmWQAy7D7PT9/HSkHr5NDxzijnJCen5Ep7u4fEaa7dXENXXRcfGrz5KvjOiYihk2HvXq5AlBusYcglvUmkLcyRwMwMyd2BRJ1o13labIOfWIghKyV5pLliElJN ec2-user@ip-172-31-29-125.ec2.internal"
}

resource "aws_ecr_repository" "assignment2-cats-repository" {
  name                 = "cats-repo"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository_policy" "cats-repo-policy" {
  repository = aws_ecr_repository.assignment2-cats-repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the cat repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository" "assignment2-dogs-repository" {
  name                 = "dogs-repo"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository_policy" "dogs-repo-policy" {
  repository = aws_ecr_repository.assignment2-dogs-repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the cat repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}
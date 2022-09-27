provider "aws" {
    region= "us-east-1"
   
}

resource  "aws_key_pair" "key" {
    key_name = "sample-key"
    public_key = "ssh-rsa ###########################################################tVk= acreddy@ckReddy"
}

resource "aws_instance" "demo-server" {
    ami= "ami-026b57f3c383c2eec"
    instance_type = "t2.micro"
    subnet_id = "subnet-0b***************"
    security_groups = ["sg-05e****************"]
    key_name =  aws_key_pair.key.id

    tags= {
        Name= "terraform-ec2"
    } 
}





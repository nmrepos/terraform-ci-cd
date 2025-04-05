provider "aws"{
    region = "us-east-1"
}

resource "aws_instance" "example"{
    ami = "ami-0f214d1b3d031dc53"
    instance_type = "t2.micro"
    count = var.core_count
    tags = {
        Name = "ExampleInstance"
    }
}
provider "aws" {
  region = "ca-central-1"

}
resource "aws_instance" "db" {
  ami           = "ami-06c3426233c180fef"
  instance_type = "t2.micro"
  tags = {
    "Name" = "db_server"
  }

}
resource "aws_instance" "web" {
  ami             = "ami-06c3426233c180fef"
  instance_type   = "t2.micro"
  user_data       = file("morayo.sh")
  security_groups = [aws_security_group.webip.name]
  tags = {
    "Name" = "web-server"
  }
}
resource "aws_eip" "web_elastic" {
  instance = aws_instance.web.id
}
variable "ingressrules" {
  type    = list(number)
  default = [443, 80]
}
variable "egressrules" {
  type    = list(number)
  default = [443, 80, 25, 3306, 8080]
}
resource "aws_security_group" "webip" {
  name = "Allow webtraffic"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    iterator = port
    for_each = var.egressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
output "dbprivate" {
  value = aws_instance.db.private_ip
}
output "webpublic" {
  value = aws_eip.web_elastic.public_ip
}
  
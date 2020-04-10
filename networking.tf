data "aws_subnet" "private1a" {
  tags = {
   subnet = "private1a"
  }
 }

data "aws_subnet" "private1b" {
  tags = {
   subnet = "private1b"
  }
 }

data "aws_subnet" "private1c" {
  tags = {
   subnet = "private1c"
  }
 }


output "private1a" {
  value = "${data.aws_subnet.private1a.cidr_block}"
}
output "private1b" {
  value = "${data.aws_subnet.private1b.cidr_block}"
}
output "private1c" {
  value = "${data.aws_subnet.private1c.cidr_block}"
}

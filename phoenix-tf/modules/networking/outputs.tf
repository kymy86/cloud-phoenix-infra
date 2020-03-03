output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

output "public_azs" {
  value = aws_subnet.public_subnet.*.availability_zone
}

output "public_cidrs" {
  value = aws_subnet.public_subnet.*.cidr_block
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
}

output "private_azs" {
  value = aws_subnet.private_subnet.*.availability_zone
}

output "nat_gateway" {
  value = aws_nat_gateway.nat_gateway.id
}

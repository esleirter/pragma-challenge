output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = [
    aws_subnet.subnet_public_1a.id,
    aws_subnet.subnet_public_1b.id,
    aws_subnet.subnet_public_1c.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.subnet_private_1a.id,
    aws_subnet.subnet_private_1b.id,
    aws_subnet.subnet_private_1c.id
  ]
}

output "nat_gateway_ids" {
  value = [
    aws_nat_gateway.nat_gateway_1a.id,
    aws_nat_gateway.nat_gateway_1b.id,
    aws_nat_gateway.nat_gateway_1c.id
  ]
}

output "nat_eip_addresses" {
  value = [
    aws_eip.eip_1a.public_ip,
    aws_eip.eip_1b.public_ip,
    aws_eip.eip_1c.public_ip
  ]
}

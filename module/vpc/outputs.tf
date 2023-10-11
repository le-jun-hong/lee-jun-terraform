output "EC2_Pub_IP" {
  value       = aws_eip.BastionHost_eip.public_ip
  description = "EC2 Instance Public IP Address"
}
output "public_subnet_1" {
  value       = aws_subnet.my_vpc_public_subnet1.id
  description = "public-subnet-1-id"
}
output "public_subnet_2" {
  value       = aws_subnet.my_vpc_public_subnet2.id
  description = "public-subnet-2-id"
}
/* ==================================================== */
/* ==================================================== */
/* ==================================================== */
output "private_subnet_1" {
  value       = aws_subnet.my_vpc_private_subnet1.id
  description = "private-subnet-1-id"
}
output "private_subnet_2" {
  value       = aws_subnet.my_vpc_private_subnet2.id
  description = "private-subnet-2-id"
}
output "private_subnet_3" {
  value       = aws_subnet.my_vpc_private_subnet3.id
  description = "private-subnet-3-id"
}
output "private_subnet_4" {
  value       = aws_subnet.my_vpc_private_subnet4.id
  description = "private-subnet-4-id"
}
output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "vpc_id"
}
output "se_gr" {
  value = aws_security_group.db_sg.id
}
output "ALB_DNS" {
  value       = aws_lb.my_lb.dns_name
  description = "Load Balancer Domain Name"
}
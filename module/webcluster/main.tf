resource "aws_security_group" "http_sg" {
  name        = "HTTP Web Server"
  description = "Allow HTTP Traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_launch_configuration" "my_ASG_Launch" {
  image_id        = "ami-0ea4d4b8dc1e46212"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.http_sg.id]
  user_data       = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "Hello World from $(hostname -f)" > /var/www/html/index.html
  EOF

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_target_group" "my_lb_tg" {
  name     = "my-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_autoscaling_group" "my_ASG" {
  launch_configuration = aws_launch_configuration.my_ASG_Launch.name
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = [var.private_subnet1, var.private_subnet3]
  target_group_arns    = [aws_lb_target_group.my_lb_tg.arn]
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "my_ASG_EC2Instance"
    propagate_at_launch = true
  }
}



resource "aws_lb" "my_lb" {
  name               = "my-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_sg.id]
  subnets            = [var.public_subnet1, var.public_subnet2]
}


resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 : Page Not Found"
      status_code  = "404"
    }
  }
}


resource "aws_lb_listener_rule" "my_lb_listener_rule" {
  listener_arn = aws_lb_listener.my_lb_listener.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_tg.arn
  }
}

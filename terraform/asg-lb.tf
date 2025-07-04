
# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "ec2-app-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on         = [aws_internet_gateway.igw]
}

# Target Group for ALB
resource "aws_lb_target_group" "alb_ec2_tg" {
  name     = "ec2-web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ec2_vpc.id
  tags = {
    Name = "ec2-alb_ec2_tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
  }
  tags = {
    Name = "ec2-alb-listener"
  }
}

# Launch Template for EC2 Instances
resource "aws_launch_template" "ec2_launch_template" {
  name = "ec2-web-server"

  image_id      = "ami-061ad72bc140532fd"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = filebase64("userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-ec2-web-server"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_asg" {
  name                = "ec2-web-server-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  target_group_arns   = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  health_check_type = "EC2"
}


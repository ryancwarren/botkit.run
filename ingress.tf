
resource "aws_lb" "node_echo_http" {
  name               = "node-echo-http"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.allow_ingress.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  
  depends_on = [
    aws_subnet.public1,
    aws_subnet.public1
  ]
}

resource "aws_lb_target_group" "node_echo_http" {
  name     = "node-echo-http"
  port     = 8000
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "TCP"
    port                = 8000
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "node_echo_http" {
  load_balancer_arn = aws_lb.node_echo_http.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_echo_http.arn
  }

  depends_on = [
    aws_lb_target_group.node_echo_http,
    aws_lb.node_echo_http
  ]
}

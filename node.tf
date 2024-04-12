// ami-05d4121edd74a9f06
// ami-03bf3988b7f05e864 - node-echo-http port 8000
// ami-0f7251c804c8237cf
// ami-0ec2b46b6038d2e35
// 	ami-05025ff3bc06f14b9
// ami-0c8a82b66cb24afc6

resource "aws_key_pair" "nodekey" {
  key_name   = "nodekey"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfigyiQCDrkWYRYwai6TypTOCpAshQy88VtV9UfOOdn user@alpha"
}

resource "aws_instance" "node" {
  ami           = "ami-0c8a82b66cb24afc6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  key_name      = "nodekey"
  vpc_security_group_ids = [aws_security_group.allow_ingress.id]
}

resource "aws_placement_group" "node_echo_http" {
  name     = "node_echo_http"
  strategy = "partition"
}

resource "aws_launch_template" "node_echo_http" {
    name_prefix   = "node_echo_http"
    image_id      = "ami-0c8a82b66cb24afc6"
    instance_type = "t2.micro"
    key_name      = "nodekey"
    vpc_security_group_ids = [aws_security_group.allow_ingress.id]

    # Specify the user data to execute the Python script on startup
    user_data     = base64encode("#!/usr/bin/env bash\npython3 /home/ubuntu/https_server.py")

    lifecycle {
        prevent_destroy = false
    }
}

resource "aws_autoscaling_group" "node_echo_http" {
  name                      = "node-echo-http"
  max_size                  = 4
  min_size                  = 4
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.node_echo_http.id
  vpc_zone_identifier       = [aws_subnet.public1.id]
  target_group_arns         = [aws_lb_target_group.node_echo_http.arn]

  launch_template {
    id = aws_launch_template.node_echo_http.id
  }

  lifecycle {
    create_before_destroy = false
    prevent_destroy = false
  }

  depends_on = [
    aws_lb_target_group.node_echo_http,
    aws_lb.node_echo_http
  ]
}
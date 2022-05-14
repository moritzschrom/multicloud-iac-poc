resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "my_subnets" {
  count             = 3
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route_table" "my_vpc_public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "my_vpc_public_associations" {
  for_each       = { for index, my_subnet in aws_subnet.my_subnets : index => my_subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.my_vpc_public.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound connections"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "elb_http" {
  name        = "elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-"

  image_id      = "ami-0022f774911c1d690" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type = "t2.micro"

  security_groups             = [aws_security_group.allow_http.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "my_elb" {
  name            = "web-elb"
  security_groups = [aws_security_group.elb_http.id]
  subnets         = [for my_subnet in aws_subnet.my_subnets : my_subnet.id]

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_autoscaling_group" "my_asg" {
  name = "${aws_launch_configuration.web.name}-asg"

  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  health_check_type = "ELB"
  load_balancers = [
    aws_elb.my_elb.id
  ]

  launch_configuration = aws_launch_configuration.web.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = [for my_subnet in aws_subnet.my_subnets : my_subnet.id]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "main"
  subnet_ids = [for my_subnet in aws_subnet.my_subnets : my_subnet.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_db_instance" "my_db" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "14.1"
  instance_class       = "db.t3.micro"
  db_name              = "my_db"
  username             = "postgres"
  password             = "postgres"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

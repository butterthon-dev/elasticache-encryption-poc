resource "aws_lb" "this" {
  name                       = "${var.name_prefix}-alb-${var.name}"
  load_balancer_type         = "application"
  internal                   = var.internal
  subnets                    = var.subnet_ids
  security_groups            = var.security_group_ids
  drop_invalid_header_fields = true
}

# Define composite variables for resources
module "label" {
  source     = "git::https://github.com/betterworks/terraform-null-label.git?ref=tags/0.14.0"
  enabled    = var.enabled
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

#
# Security Group Resources
#
resource "aws_security_group" "default" {
  count  = var.enabled == "true" ? 1 : 0
  vpc_id = var.vpc_id
  name   = module.label.id

  ingress {
    from_port       = var.port # Redis
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.security_groups
  }
  ingress {
    from_port   = var.port # Redis
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.label.tags
}

locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default.*.name)
}

resource "aws_elasticache_subnet_group" "default" {
  count      = var.enabled == "true" && var.elasticache_subnet_group_name == "" && length(var.subnets) > 0 ? 1 : 0
  name       = module.label.id
  subnet_ids = var.subnets
}

resource "aws_elasticache_parameter_group" "default" {
  count  = var.enabled == "true" ? 1 : 0
  name   = trimspace(replace("${var.namespace}-${var.stage}-${var.name}-${replace(var.engine_version, ".", "-")}", "--", "-"))
  family = var.family
  dynamic "parameter" {
    for_each = var.parameter
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elasticache_replication_group" "default" {
  count = var.enabled == "true" ? 1 : 0

  auth_token                  = var.auth_token
  replication_group_id        = var.replication_group_id == "" ? module.label.id : var.replication_group_id
  description                 = module.label.id
  node_type                   = var.instance_type
  num_cache_clusters          = var.cluster_size
  port                        = var.port
  parameter_group_name        = aws_elasticache_parameter_group.default[0].name
  preferred_cache_cluster_azs = slice(var.availability_zones, 0, var.cluster_size)
  automatic_failover_enabled  = var.automatic_failover
  subnet_group_name           = local.elasticache_subnet_group_name
  security_group_ids          = [aws_security_group.default[0].id]
  maintenance_window          = var.maintenance_window
  notification_topic_arn      = var.notification_topic_arn
  engine_version              = var.engine_version
  at_rest_encryption_enabled  = var.at_rest_encryption_enabled
  transit_encryption_enabled  = var.transit_encryption_enabled
  multi_az_enabled            = var.multi_az_enabled

  tags = module.label.tags

  # Ensure the replication group depends on the parameter group being created
  depends_on = [aws_elasticache_parameter_group.default]

  lifecycle {
    ignore_changes = [preferred_cache_cluster_azs]
  }
}


#
# CloudWatch Resources
#
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = var.enabled && var.enable_metric_alarms ? 1 : 0
  alarm_name          = "${module.label.id}-cpu-utilization"
  alarm_description   = "Redis cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = tolist(aws_elasticache_replication_group.default[0].member_clusters)[0]
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = var.enabled && var.enable_metric_alarms ? 1 : 0
  alarm_name          = "${module.label.id}-freeable-memory"
  alarm_description   = "Redis cluster freeable memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "DatabaseCapacityUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_percent

  dimensions = {
    CacheClusterId = tolist(aws_elasticache_replication_group.default[0].member_clusters)[0]
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
}

module "dns" {
  source    = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.8.0"
  enabled   = var.enabled == "true" && length(var.zone_id) > 0 ? "true" : "false"
  namespace = var.namespace
  dns_name  = length(var.host_name) > 0 ? var.host_name : module.label.id
  stage     = var.stage
  ttl       = 60
  zone_id   = var.zone_id
  records   = aws_elasticache_replication_group.default.*.primary_endpoint_address
}


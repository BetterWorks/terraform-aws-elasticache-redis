variable "namespace" {
  default     = "global"
  description = "Namespace"
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "stage" {
  default     = "default"
  description = "Stage"
}

variable "name" {
  default     = "redis"
  description = "Name"
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "AWS security group ids"
}

variable "vpc_id" {
  description = "AWS VPC id"
}

variable "subnets" {
  type        = list(string)
  description = "AWS subnet IDs"
  default     = []
}

variable multi_az_enabled {
  type        = bool
  description = "Enables multi-az cluster"
  default     = false
}

variable "elasticache_subnet_group_name" {
  type        = string
  description = "Subnet group name for the ElastiCache instance"
  default     = ""
}

variable "maintenance_window" {
  default     = "wed:03:00-wed:04:00"
  description = "Maintenance window"
}

variable "cluster_size" {
  default     = "1"
  description = "Count of nodes in cluster"
}

variable "port" {
  default     = "6379"
  description = "Redis port"
}

variable "instance_type" {
  default     = "cache.t2.micro"
  description = "Elastic cache instance type"
}

variable "family" {
  default     = "redis4.0"
  description = "Redis family "
}

variable "parameter" {
  #  type        = list(string)
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from one Redis family to another"
}

variable "engine_version" {
  default     = "4.0.10"
  description = "Redis engine version"
}

variable "at_rest_encryption_enabled" {
  default     = "false"
  description = "Enable encryption at rest"
}

variable "transit_encryption_enabled" {
  default     = "true"
  description = "Enable TLS"
}

variable "notification_topic_arn" {
  default     = ""
  description = "Notification topic arn"
}

variable "enable_metric_alarms" {
  default     = false
  description = "If true will create metric alarms"
}

variable "alarm_cpu_threshold_percent" {
  default     = "85"
  description = "CPU threshold alarm level"
}

variable "alarm_memory_threshold_percent" {
  # 10MB
  default     = "85"
  description = "Ram threshold alarm level"
}

variable "alarm_actions" {
  type        = list(string)
  description = "Alarm action list"
  default     = []
}

variable "ok_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Number (ARN)"
  default     = []
}

variable "apply_immediately" {
  default     = "true"
  description = "Apply changes immediately"
}

variable "automatic_failover" {
  default     = "false"
  description = "Automatic failover (Not available for T1/T2 instances)"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zone ids"
  default     = []
}

variable "zone_id" {
  default     = ""
  description = "Route53 DNS Zone id"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter between `name`, `namespace`, `stage` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes (_e.g._ \"1\")"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ map(\"BusinessUnit\",\"ABC\")"
  default     = {}
}

variable "auth_token" {
  type        = string
  description = "Auth token for password protecting redis, transit_encryption_enabled must be set to 'true'! Password must be longer than 16 chars"
  default     = ""
}

variable "replication_group_id" {
  type        = string
  description = "Replication group ID with the following constraints: \nA name must contain from 1 to 20 alphanumeric characters or hyphens. \n The first character must be a letter. \n A name cannot end with a hyphen or contain two consecutive hyphens."
  default     = ""
}

variable "host_name" {
  type        = string
  description = "The hostname to create in the DNS zone."
  default     = ""
}
variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the cluster"
}

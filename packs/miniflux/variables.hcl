variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

// Postgres variables
variable "postgres_group_update" {
  description = "The Postgres update configuration options."
  type        = object({
    min_healthy_time  = string
    healthy_deadline  = string
    progress_deadline = string
    auto_revert       = bool
  })
  default = {
    min_healthy_time  = "10s",
    healthy_deadline  = "5m",
    progress_deadline = "10m",
    auto_revert       = true,
  }
}

variable "postgres_group_volume" {
  description = "The source volume name, as defined in Nomad's client configuration, to be used by Postgres."
  type        = string
  default     = "miniflux-postgres"
}

variable "postgres_group_register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = true
}

variable "postgres_group_consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "postgres"
}

variable "postgres_group_consul_service_port" {
  description = "The consul service port for the application."
  type        = string
  default     = "5432"
}

variable "postgres_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "database"
  ]
}

variable "postgres_group_has_health_check" {
  description = "If you want to register a health check in consul. Port needs to be exposed."
  type        = bool
  default     = false
}

variable "postgres_group_health_check" {
  description = ""
  type = object({
    port     = number
    interval = string
    timeout  = string
  })

  default = {
    port     = 5432
    interval = "10s"
    timeout  = "2s"
  }
}

variable "postgres_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "postgres_task_image" {
  description = "Postgres' Docker image."
  type        = string
  default     = "postgres:15.2"
}

variable "postgres_task_volume_path" {
  description = "The volume's absolute path in the host, as defined in Nomad's client configuration, to be used by Postgres."
  type        = string
  default     = "/var/lib/postgres"
}

variable "postgres_task_env_vars" {
  description = "Postgres' environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "POSTGRES_USER"
      value = "miniflux"
    },
    {
      key   = "POSTGRES_PASSWORD"
      value = "secret"
    }
  ]
}

variable "postgres_task_resources" {
  description = "The resources to assign to the Postgres service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

// Miniflux variables
variable "miniflux_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "http"
    port = 80
  }]
}

variable "miniflux_group_update" {
  description = "The Miniflux update configuration options."
  type        = object({
    min_healthy_time  = string
    healthy_deadline  = string
    progress_deadline = string
    auto_revert       = bool
  })
  default = {
    min_healthy_time  = "10s",
    healthy_deadline  = "5m",
    progress_deadline = "10m",
    auto_revert       = true,
  }
}

variable "miniflux_group_register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = true
}

variable "miniflux_group_consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "miniflux"
}

variable "miniflux_group_consul_service_port" {
  description = "The consul service port for the application."
  type        = string
  default     = "http"
}

variable "miniflux_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "app"
  ]
}

variable "miniflux_group_upstreams" {
  description = "Consul Connect upstream configuration."
  type = list(object({
    name = string
    port = number
  }))
  default = [{
    name = "postgres"
    port = 5432
  }]
}

variable "miniflux_group_has_health_check" {
  description = "If you want to register a health check in consul"
  type        = bool
  default     = true
}

variable "miniflux_group_health_check" {
  description = ""
  type = object({
    name     = string
    path     = string
    port     = string
    interval = string
    timeout  = string
  })

  default = {
    name     = "miniflux"
    path     = "/"
    port     = "http"
    interval = "10s"
    timeout  = "2s"
  }
}

variable "miniflux_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "miniflux_task_image" {
  description = "Miniflux Docker image."
  type        = string
  default     = "miniflux/miniflux:2.0.42"
}

variable "miniflux_task_env_vars" {
  description = "Miniflux environment variables."
  type = list(object({
    key   = string
    value = string
  }))
    default = [
    {
      key   = "DATABASE_URL"
      value = "postgres://miniflux:secret@db/miniflux?sslmode=disable"
    },
    {
      key   = "RUN_MIGRATIONS"
      value = "1"
    },
    {
      key   = "CREATE_ADMIN"
      value = "1"
    },
    {
      key   = "ADMIN_USERNAME"
      value = "admin"
    },
    {
      key   = "ADMIN_PASSWORD"
      value = "password"
    }
  ]
}

variable "miniflux_task_resources" {
  description = "The resources to assign to the Miniflux service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

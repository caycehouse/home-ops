job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .miniflux.datacenters  | toStringList ]]
  type = "service"

  group "postgres" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ .miniflux.postgres_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .miniflux.postgres_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .miniflux.postgres_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .miniflux.postgres_group_update.auto_revert ]]
    }

    volume "postgres" {
      type = "host"
      read_only = false
      source = [[ .miniflux.postgres_group_volume | quote ]]
    }

    [[- if .miniflux.postgres_group_register_consul_service ]]
    service {
      name = [[ .miniflux.postgres_group_consul_service_name | quote ]]
      port = [[ .miniflux.postgres_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .miniflux.postgres_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      connect {
        sidecar_service {}
      }

      [[- if .miniflux.postgres_group_has_health_check ]]
      check {
        name     = "postgres"
        type     = "tcp"
        port     = [[ .miniflux.postgres_group_health_check.port ]]
        interval = [[ .miniflux.postgres_group_health_check.interval | quote ]]
        timeout  = [[ .miniflux.postgres_group_health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .miniflux.postgres_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "postgres" {
      driver = "docker"

      config {
        image = [[.miniflux.postgres_task_image | quote]]
      }

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      [[- $postgres_task_env_vars_length := len .miniflux.postgres_task_env_vars ]]
      [[- if not (eq $postgres_task_env_vars_length 0) ]]
      env {
        [[- range $var := .miniflux.postgres_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .miniflux.postgres_task_resources.cpu ]]
        memory = [[ .miniflux.postgres_task_resources.memory ]]
      }
    }
  }

  group "miniflux" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := .miniflux.miniflux_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .miniflux.miniflux_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .miniflux.miniflux_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .miniflux.miniflux_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .miniflux.miniflux_group_update.auto_revert ]]
    }

    [[- if .miniflux.miniflux_group_register_consul_service ]]
    service {
      name = [[ .miniflux.miniflux_group_consul_service_name | quote ]]
      port = [[ .miniflux.miniflux_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .miniflux.miniflux_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := .miniflux.miniflux_group_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }

      [[- if .miniflux.miniflux_group_has_health_check ]]
      check {
        name     = [[ .miniflux.miniflux_group_health_check.name | quote ]]
        type     = "http"
        port     = [[ .miniflux.miniflux_group_health_check.port | quote ]]
        path     = [[ .miniflux.miniflux_group_health_check.path | quote ]]
        interval = [[ .miniflux.miniflux_group_health_check.interval | quote ]]
        timeout  = [[ .miniflux.miniflux_group_health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .miniflux.miniflux_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "miniflux" {
      driver = "docker"

      config {
        image = [[.miniflux.miniflux_task_image | quote]]
      }

      [[- $miniflux_task_env_vars_length := len .miniflux.miniflux_task_env_vars ]]
      [[- if not (eq $miniflux_task_env_vars_length 0) ]]
      env {
        [[- range $var := .miniflux.miniflux_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .miniflux.miniflux_task_resources.cpu ]]
        memory = [[ .miniflux.miniflux_task_resources.memory ]]
      }
    }
  }
}

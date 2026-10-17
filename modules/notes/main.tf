resource "docker_network" "app" {
  name = "${var.name_prefix}-network"
}

resource "docker_volume" "postgres" {
  name = "${var.name_prefix}-pgdata"
}

resource "docker_image" "api" {
  name         = var.api_image
  keep_locally = true
}

resource "docker_image" "postgres" {
  name         = "postgres:17-bookworm@sha256:3645570cccdfa447589da9f57dd740faa29b30938e861289a5574b6ca6b03826"
  keep_locally = true
}

resource "docker_container" "db" {
  name    = "${var.name_prefix}-db"
  image   = docker_image.postgres.image_id
  restart = "unless-stopped"
  env = [
    "POSTGRES_DB=notes",
    "POSTGRES_USER=lab",
    "POSTGRES_PASSWORD_FILE=/run/secrets/db_password"
  ]
  networks_advanced {
    name    = docker_network.app.name
    aliases = ["db"]
  }
  mounts {
    type   = "volume"
    source = docker_volume.postgres.name
    target = "/var/lib/postgresql/data"
  }
  mounts {
    type      = "bind"
    source    = var.password_file
    target    = "/run/secrets/db_password"
    read_only = true
  }
  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U lab -d notes"]
    interval = "5s"
    timeout  = "3s"
    retries  = 12
  }
  wait         = true
  wait_timeout = 120
}

resource "docker_container" "api" {
  name          = "${var.name_prefix}-api"
  image         = docker_image.api.image_id
  restart       = "unless-stopped"
  read_only     = true
  user          = "10001:10001"
  tmpfs         = { "/tmp" = "rw,noexec,nosuid,size=64m" }
  security_opts = ["no-new-privileges:true"]
  capabilities {
    drop = ["ALL"]
  }
  env = [
    "DB_HOST=db",
    "DB_NAME=notes",
    "DB_USER=lab",
    "DB_PASSWORD_FILE=/run/secrets/db_password"
  ]
  networks_advanced {
    name = docker_network.app.name
  }
  mounts {
    type      = "bind"
    source    = var.password_file
    target    = "/run/secrets/db_password"
    read_only = true
  }
  ports {
    internal = 8000
    external = var.api_port
    ip       = "127.0.0.1"
  }
  healthcheck {
    test         = ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/readyz', timeout=3)"]
    interval     = "5s"
    timeout      = "4s"
    retries      = 6
    start_period = "10s"
  }
  depends_on   = [docker_container.db]
  wait         = true
  wait_timeout = 120
}

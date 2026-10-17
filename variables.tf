variable "docker_host" {
  description = "Docker daemon endpoint / Endpoint do daemon Docker."
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "name_prefix" {
  description = "Dedicated resource prefix / Prefixo exclusivo dos recursos."
  type        = string
  default     = "terraform-lab"
  validation {
    condition     = can(regex("^terraform-lab(-[a-z0-9-]+)?$", var.name_prefix))
    error_message = "Use terraform-lab or terraform-lab-<lowercase suffix>."
  }
}

variable "api_port" {
  description = "Local API port / Porta local da API."
  type        = number
  default     = 8002
  validation {
    condition     = var.api_port >= 1024 && var.api_port <= 65535 && floor(var.api_port) == var.api_port
    error_message = "api_port must be an integer between 1024 and 65535."
  }
}

variable "api_image" {
  description = "API image pinned by digest / Imagem da API fixada por digest."
  type        = string
  default     = "ghcr.io/tommmdl/docker-lab@sha256:d8fdaffb99e0ac514b9e031ac9204b89fc2702112d198d1bebedd9d351fd19f0"
  validation {
    condition     = can(regex("^ghcr.io/tommmdl/docker-lab@sha256:[a-f0-9]{64}$", var.api_image))
    error_message = "Use the docker-lab GHCR image with a full sha256 digest."
  }
}

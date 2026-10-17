terraform {
  required_version = ">= 1.14.9, < 2.0.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
  backend "local" {
    path = ".local/terraform.tfstate"
  }
}

provider "docker" {
  host = var.docker_host
}

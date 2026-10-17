output "resource_names" {
  value = {
    api     = docker_container.api.name
    db      = docker_container.db.name
    network = docker_network.app.name
    volume  = docker_volume.postgres.name
  }
}

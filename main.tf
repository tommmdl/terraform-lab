module "notes" {
  source = "./modules/notes"

  name_prefix   = var.name_prefix
  api_port      = var.api_port
  api_image     = var.api_image
  password_file = abspath("${path.root}/.local/db-password")
}

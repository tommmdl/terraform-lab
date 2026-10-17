output "api_url" {
  description = "Local application URL / URL local da aplicação."
  value       = "http://127.0.0.1:${var.api_port}"
}

output "resource_names" {
  description = "Names managed by this state / Nomes gerenciados por este state."
  value       = module.notes.resource_names
}

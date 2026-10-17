variable "name_prefix" { type = string }
variable "api_port" { type = number }
variable "api_image" { type = string }
variable "password_file" {
  description = "Existing host file; contents are not read into state."
  type        = string
}

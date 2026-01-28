variable "domain_name" {
  description = "Dominio raíz (ej: midominio.com)"
  type        = string
}

variable "tags" {
  description = "Mapa de tags para aplicar a los recursos"
  type        = map(string)
}
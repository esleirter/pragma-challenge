output "valkey_cache_names" {
  description = "Lista con los nombres de las instancias Valkey creadas"
  value       = [for c in aws_elasticache_serverless_cache.valkey_cache : c.name]
}

output "valkey_cache_endpoints" {
  description = "Lista de endpoints de cada instancia Valkey"
  value       = [for c in aws_elasticache_serverless_cache.valkey_cache : c.endpoint]
}
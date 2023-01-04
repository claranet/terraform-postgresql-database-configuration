output "schema" {
  description = "Database schema name"
  value       = postgresql_schema.db_schema.name
}

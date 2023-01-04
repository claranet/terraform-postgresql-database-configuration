variable "user" {
  type        = string
  description = "Database schema owner user."
}

variable "database" {
  type        = string
  description = "Database to apply hardening to."
}

variable "schema_name" {
  type        = string
  description = "Schema custom name to create associated to the Database. Database name used if not set."
  default     = null
}

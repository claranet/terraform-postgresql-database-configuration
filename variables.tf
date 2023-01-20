variable "database_admin_user" {
  type        = string
  description = "Database schema admin user."
}

variable "administrator_login" {
  type        = string
  description = "Server administrator user name."
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

variable "tables_privileges" {
  description = "User tables privileges, all privileges if not defined."
  type        = list(string)
  default     = null
}

variable "sequences_privileges" {
  description = "User sequences privileges, all privileges if not defined."
  type        = list(string)
  default     = null
}

variable "functions_privileges" {
  description = "User functions privileges, execution privileges if not defined."
  type        = list(string)
  default     = null
}

resource "postgresql_grant" "revoke_public" {
  database    = var.database
  role        = "public"
  schema      = "public"
  object_type = "schema"
  privileges  = []
}

resource "postgresql_schema" "db_schema" {
  name     = coalesce(var.schema_name, var.database)
  database = var.database
  owner    = var.database_admin_user
}

resource "postgresql_default_privileges" "user_tables_privileges" {
  role     = var.database_admin_user
  database = var.database
  schema   = postgresql_schema.db_schema.name

  object_type = "table"
  owner       = var.database_admin_user
  privileges = var.tables_privileges != null ? var.tables_privileges : [
    "SELECT",
    "INSERT",
    "UPDATE",
    "DELETE",
    "TRUNCATE",
    "REFERENCES",
    "TRIGGER",
  ]
}

resource "postgresql_default_privileges" "user_sequences_privileges" {
  role     = var.database_admin_user
  database = var.database
  schema   = postgresql_schema.db_schema.name

  object_type = "sequence"
  owner       = var.administrator_login
  privileges = var.sequences_privileges != null ? var.sequences_privileges : [
    "SELECT",
    "UPDATE",
    "USAGE",
  ]
}

resource "postgresql_default_privileges" "user_functions_privileges" {
  role     = var.database_admin_user
  database = var.database
  schema   = postgresql_schema.db_schema.name

  object_type = "function"
  owner       = var.administrator_login
  privileges = var.functions_privileges != null ? var.functions_privileges : [
    "EXECUTE",
  ]
}

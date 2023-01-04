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
  owner    = var.user
}

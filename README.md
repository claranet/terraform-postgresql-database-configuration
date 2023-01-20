# PostgreSQL database configuration
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/database-configuration/postgresql/)

Terraform module using `PostgreSQL` provider to help configuring an existing database.
This module will be used combined with others PostgreSQL modules (like [`azure-db-postgresql-flexible`](https://registry.terraform.io/modules/claranet/db-postgresql-flexible/azurerm/) or [`postgresql-users`](https://registry.terraform.io/modules/claranet/users/postgresql/) for example).

This module revoke privileges on the default `public` PostgreSQL schema regarding the [CVE-2018-1058](https://wiki.postgresql.org/wiki/A_Guide_to_CVE-2018-1058%3A_Protect_Your_Search_Path#Do_not_allow_users_to_create_new_objects_in_the_public_schema) and creates a dedicated schema for the specified database.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "db_pg_flex" {
  source  = "claranet/db-postgresql-flexible/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  allowed_cidrs = {}

  databases_names     = ["mydatabase"]
  databases_collation = { mydatabase = "en_US.UTF8" }
  databases_charset   = { mydatabase = "UTF8" }

  logs_destinations_ids = []
}

provider "postgresql" {
  host      = module.db_pg_flex.postgresql_flexible_fqdn
  port      = 5432
  username  = module.db_pg_flex.postgresql_flexible_administrator_login
  password  = var.administrator_password
  sslmode   = "require"
  superuser = false
}

module "postgresql_users" {
  source  = "claranet/users/postgresql"
  version = "x.x.x"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  administrator_login = module.db_pg_flex.postgresql_flexible_administrator_login

  database = each.key
}

module "postgresql_configuration" {
  source  = "claranet/database-configuration/postgresql"
  version = "x.x.x"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  administrator_login = module.db_pg_flex.postgresql_flexible_administrator_login

  database_admin_user = module.postgresql_users[each.key].user
  database            = each.key
  schema_name         = each.key
}
```

## Providers

| Name | Version |
|------|---------|
| postgresql | >= 1.14 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [postgresql_default_privileges.user_functions_privileges](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.user_sequences_privileges](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.user_tables_privileges](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_grant.revoke_public](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_schema.db_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| administrator\_login | Server administrator user name. | `string` | n/a | yes |
| database | Database to apply hardening to. | `string` | n/a | yes |
| database\_admin\_user | Database schema admin user. | `string` | n/a | yes |
| functions\_privileges | User functions privileges, execution privileges if not defined. | `list(string)` | `null` | no |
| schema\_name | Schema custom name to create associated to the Database. Database name used if not set. | `string` | `null` | no |
| sequences\_privileges | User sequences privileges, all privileges if not defined. | `list(string)` | `null` | no |
| tables\_privileges | User tables privileges, all privileges if not defined. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| database | Database name |
| schema | Database schema name |
<!-- END_TF_DOCS -->
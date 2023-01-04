# PostgreSQL hardening module
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/hardening/postgresql/)

Terraform module using `PostgreSQL` provider tp apply hardening on an existing database.
This module will be used in combination with others PostgreSQL modules (like [`azure-db-postgresql-flexible`](https://registry.terraform.io/modules/claranet/db-postgresql-flexible/azurerm/) for example).

This module revoke privileges on the default `public` PostgreSQL schema and creates a dedicated schema for the specified database.

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

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
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

  tier               = "GeneralPurpose"
  size               = "D2s_v3"
  storage_mb         = 32768
  postgresql_version = 13

  allowed_cidrs = {
    "1" = "1.2.3.4/29"
    "2" = "12.34.56.78/32"
  }

  backup_retention_days        = 14
  geo_redundant_backup_enabled = true

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  databases_names     = ["mydatabase"]
  databases_collation = { mydatabase = "en_US.UTF8" }
  databases_charset   = { mydatabase = "UTF8" }

  maintenance_window = {
    day_of_week  = 3
    start_hour   = 3
    start_minute = 0
  }

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]

  extra_tags = {
    foo = "bar"
  }
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
  # source  = "claranet/users/postgresql"
  # version = "x.x.x"
  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/postgresql-users.git?ref=AZ-930_postgresql_users_module"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  administrator_login = module.db_pg_flex.postgresql_flexible_administrator_login

  user     = each.key
  database = each.key
}

module "postgresql_hardening" {
  # source  = "claranet/hardening/postgresql"
  # version = "x.x.x"
  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/postgresql-hardening.git?ref=AZ-930_postgresql_hard"

  for_each = toset(module.db_pg_flex.postgresql_flexible_databases_names)

  user     = each.key
  database = each.key
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
| [postgresql_grant.revoke_public](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_schema.db_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| database | Database to apply hardening to. | `string` | n/a | yes |
| schema\_name | Schema custom name to create associated to the Database. Database name used if not set. | `string` | `null` | no |
| user | Database schema owner user. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| schema | Database schema name |
<!-- END_TF_DOCS -->
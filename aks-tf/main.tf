provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}
resource "azurerm_cosmosdb_account" "mongo" {
  name                = var.cosmos_account_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
  consistency_policy {
    consistency_level = "Session"
  }
  capabilities {
    name = "EnableMongo"
  }
}

resource "azurerm_cosmosdb_mongo_database" "db" {
  name                = var.cosmos_db_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.mongo.name
}

resource "azurerm_cosmosdb_mongo_collection" "collection" {
  name                = var.cosmos_mongo_col
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.mongo.name
  database_name       = azurerm_cosmosdb_mongo_database.db.name
  shard_key           = "_id"

  index {
    keys   = ["_id"]
    unique = true
  }
}
output "cosmosdb_connection_string" {
  value     = azurerm_cosmosdb_account.mongo.primary_mongodb_connection_string
  sensitive = true
}

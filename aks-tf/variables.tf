variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "aks_cluster_name" { type = string }
variable "dns_prefix" { type = string }
variable "node_count" { type = number }
variable "node_vm_size" { type = string }
variable "acr_name" {
  type        = string
  description = "The globally unique name for your Azure Container Registry (3-50 lowercase letters/numbers)"
}
variable "subscription_id" { type = string }
variable "cosmos_account_name" { type = string }
variable "cosmos_db_name"      { type = string }
variable "cosmos_mongo_col"    { type = string }

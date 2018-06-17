###############################################
# Variable init

variable "resource_group_name" {
  default = ""
}

variable "linux_profile_ssh_key" {
  default = ""
}

variable "service_principal_client_secret" {
  default = ""
}

variable "remote_state_key" {
  default = ""
}

variable "service_principal_client_id" {
  default = ""
}

variable "aks_cluster_name" {
  default = ""
}

variable "kubernetes_version" {
  default = "1.8.2"
}

variable "agent_pool_profile_name" {
  default = "pool0001"
}

variable "agent_pool_count" {
  description = "Number of nodes created in agent pool"
  default     = "1"
}

variable "agent_pool_vm_size" {
  description = "Instance type for nodes created in the agent pool"
  default     = "Standard_DS2_v2"
}

variable "location" {
  default = ""
}

variable "environment" {
  default = ""
}

variable "subnet_prefixes" {
  default = ""
}

variable "client_name" {
  default = ""
}

variable "bastion_network_id" {
  default = ""
}

variable "billing_role" {
  default = ""
}

variable "billing_creator" {
  default = ""
}

variable "billing_owner" {
  default = ""
}

variable "billing_costcentre" {
  default = ""
}

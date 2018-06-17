module "aks_cluster" {
  source = "git::ssh://git@github.com:andresguisado/tfmodule-aks.git"

  location            = "${var.location}"
  resource_group_name = "${var.client_name}-aks-${var.location}-${var.environment}"

  akscluster_name         = "${var.client_name}-${var.aks_cluster_name}"
  agent_pool_profile_name = "${var.agent_pool_profile_name}"
  agent_pool_count        = "${var.agent_pool_count}"
  agent_pool_vm_size      = "${var.agent_pool_vm_size}"

  kubernetes_version = "${var.kubernetes_version}"

  linux_profile_ssh_key           = "${var.linux_profile_ssh_key}"
  service_principal_client_id     = "${var.service_principal_client_id}"
  service_principal_client_secret = "${var.service_principal_client_secret}"
  dns_prefix                      = "${var.client_name}aks${var.environment}${var.location}"

  #agent_vnet_subnet_id = "${data.terraform_remote_state.target.subnet_id_containers}"

  tags = {
    environment = "${var.environment}"
    client_name = "${var.client_name}"
    automation  = "terraform"

    billing_environment = "${var.client_name}-${var.location}-${var.environment}"
    billing_role        = "${var.billing_role}"
    billing_creator     = "${var.billing_creator}"
    billing_owner       = "${var.billing_owner}"
    billing_costcentre  = "${var.billing_costcentre}"
  }
}

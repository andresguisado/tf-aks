module "mgmt_environment" {
  source                = "git::ssh://git@github.com:andresguisado/tfmodule-aks.git?ref=aks-with-existing-spn"
  cluster_node_count    = "${var.cluster_node_count}"
  location              = "${var.location}"
  basename              = "${var.basename}"
  environment           = "${var.environment}"
  vnet_address_space    = "10.10.0.0/16"
  cluster_subnet_range  = "10.10.0.0/22"
  service_address_range = "10.10.4.0/22"
  subscription          = ""
  kubernetes_version    = "1.11.8"
}

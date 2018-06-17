terraform {
  backend "azurerm" {
  }
}

# Target state for AKS cluster

data "terraform_remote_state" "target" {
  backend = "azurerm"
  config {
    storage_account_name = "terraformstate"
    container_name       = "${var.environment}"
    key                  = "${var.cluster_name}.corenetwork.${var.location}.tfstate"
  }
}
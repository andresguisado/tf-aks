variable "location" {
  type    = "string"
  default = "westeurope"
}

variable "basename" {
  type    = "string"
}

variable "environment" {
  type    = "string"
  default = "mgmt"
}

variable "cluster_node_count" {
  type    = "string"
  default = "4"

}

variable "mgmt_config" {
  description = "Location of the mgmt config"
  default     = ""
}

###############################################
# Outputs

output "cluster_id" {
  description = "The Name of the newly created vNet"
  value       = "${module.aks_cluster.id}"
}

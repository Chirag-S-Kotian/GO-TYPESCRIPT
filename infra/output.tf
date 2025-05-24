output "instance_ip" {
  description = "External IP of the Compute Engine VM"
  value       = google_compute_instance.app_vm.network_interface[0].access_config[0].nat_ip
}
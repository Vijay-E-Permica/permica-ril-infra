output "runtime_email" {
  value = google_service_account.runtime.email
}

output "deployer_email" {
  value = google_service_account.deployer.email
}

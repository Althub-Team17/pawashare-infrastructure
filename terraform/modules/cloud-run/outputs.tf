output "service_name" {
  description = "The name of the Cloud Run service."
  value       = google_cloud_run_service.main.name
}

output "service_url" {
  description = "The URL of the deployed Cloud Run service."
  value       = google_cloud_run_service.main.status[0].url
}

output "service_location" {
  description = "The location of the Cloud Run service."
  value       = google_cloud_run_service.main.location
}

output "latest_revision_name" {
  description = "The name of the latest revision created by this deployment."
  value       = google_cloud_run_service.main.status[0].latest_created_revision_name
}

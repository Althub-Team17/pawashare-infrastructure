output "trigger_id" {
  description = "The ID of the created Cloud Build trigger."
  value       = google_cloudbuild_trigger.main.trigger_id
}

output "trigger_name" {
  description = "The name of the Cloud Build trigger."
  value       = google_cloudbuild_trigger.main.name
}

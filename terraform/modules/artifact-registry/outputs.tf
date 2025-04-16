output "repository_id" {
  description = "The ID of the created Artifact Registry repository."
  value       = google_artifact_registry_repository.main.repository_id
}

output "repository_name" {
  description = "The full name of the repository."
  value       = google_artifact_registry_repository.main.name
}

output "repository_location" {
  description = "The location of the repository."
  value       = google_artifact_registry_repository.main.location
}

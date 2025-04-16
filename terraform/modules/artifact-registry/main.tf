resource "google_artifact_registry_repository" "main" {
  # Use module input variables
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
  project       = var.project_id # Explicitly define project ID for clarity
}

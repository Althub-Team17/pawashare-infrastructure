resource "google_cloud_run_service" "main" {
  # Use module input variables
  name     = var.service_name
  location = var.location
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.container_image

        # Dynamically create env blocks from the input map
        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
        # Add other container settings like ports, resources if needed
        # ports {
        #   container_port = 8080 # Example
        # }
      }
      # Add other spec settings like service account if needed
      # service_account_name = var.service_account_email
    }
    # Add template metadata like annotations if needed
    # metadata {
    #   annotations = { ... }
    # }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Add metadata like labels if needed
  # metadata {
  #   labels = var.labels
  # }

  # Add lifecycle block if needed, e.g., ignore changes to image tag
  # lifecycle {
  #   ignore_changes = [
  #     template[0].spec[0].containers[0].image,
  #   ]
  # }
}

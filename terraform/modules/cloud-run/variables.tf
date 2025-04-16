variable "project_id" {
  description = "The GCP project ID where the service will be created."
  type        = string
}

variable "location" {
  description = "The location for the Cloud Run service."
  type        = string
}

variable "service_name" {
  description = "The name for the Cloud Run service."
  type        = string
}

variable "container_image" {
  description = "The container image to deploy (e.g., from Artifact Registry)."
  type        = string
}

variable "env_vars" {
  description = "A map of environment variables to set in the container (key=name, value=value)."
  type        = map(string)
  default     = {}
  # Mark as sensitive if the map might contain secrets passed directly
  # sensitive   = true 
}

# Optional variables (add defaults or make required as needed)
# variable "service_account_email" {
#   description = "The email of the service account to run the service as."
#   type        = string
#   default     = null 
# }

# variable "container_port" {
#   description = "The port the container listens on."
#   type        = number
#   default     = 8080
# }

# variable "labels" {
#   description = "A map of labels to apply to the service."
#   type        = map(string)
#   default     = {}
# }

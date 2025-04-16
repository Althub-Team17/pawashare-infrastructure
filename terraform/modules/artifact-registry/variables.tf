variable "project_id" {
  description = "The GCP project ID where the repository will be created."
  type        = string
}

variable "location" {
  description = "The location for the Artifact Registry repository."
  type        = string
}

variable "repository_id" {
  description = "The user-provided ID for the Artifact Registry repository."
  type        = string
}

variable "description" {
  description = "Description for the Artifact Registry repository."
  type        = string
  default     = "Docker container repository"
}

variable "format" {
  description = "The format of the repository (e.g., DOCKER, MAVEN, NPM)."
  type        = string
  default     = "DOCKER"
}

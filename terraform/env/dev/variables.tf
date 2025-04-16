# --- Provider Configuration ---
variable "project_id" {
  description = "The GCP project ID for the dev environment."
  type        = string
}

variable "region" {
  description = "The default GCP region for the dev environment."
  type        = string
}

# --- Artifact Registry ---
variable "repository_id" {
  description = "The ID for the Artifact Registry repository."
  type        = string
}

# --- Cloud Run ---
variable "service_name" {
  description = "The name for the Cloud Run service."
  type        = string
}

variable "container_image" {
  description = "The initial container image to deploy (can be updated by Cloud Build)."
  type        = string
}

# --- Cloud Build ---
variable "trigger_name" {
  description = "The desired name for the Cloud Build trigger."
  type        = string
}

variable "cloud_build_service_account_id" {
  description = "The full service account ID (projects/.../serviceAccounts/...) for Cloud Build."
  type        = string
}

variable "ar_hostname" {
  description = "The hostname of the Artifact Registry (e.g., us-central1-docker.pkg.dev)."
  type        = string
}

variable "github_owner" {
  description = "The GitHub username or organization owning the repository."
  type        = string
}

variable "github_repo_name" {
  description = "The name of the GitHub repository for the trigger."
  type        = string
}

variable "trigger_id_substitution" {
  description = "The actual Trigger ID to pass as a substitution variable (_TRIGGER_ID) in the deploy step labels."
  type        = string
}


# --- Secrets (Values provided in terraform.tfvars) ---
variable "jwt_secret_value" {
  description = "The JWT secret key."
  type        = string
  sensitive   = true
}

variable "mongodb_uri_value" {
  description = "The MongoDB connection URI."
  type        = string
  sensitive   = true
}

variable "secret_value" {
  description = "Another secret value."
  type        = string
  sensitive   = true
}

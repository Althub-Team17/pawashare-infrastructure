# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Modules ---

# Artifact Registry Repository
module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  location      = var.region # Assuming repo is in the same region as provider default
  repository_id = var.repository_id
  description   = "Cloud Run Source Deployments" # Match imported state
  format        = "DOCKER"
}

# Cloud Run Service
module "cloud_run_backend" {
  source = "../../modules/cloud-run"

  project_id      = var.project_id
  location        = var.region
  service_name    = var.service_name
  container_image = var.container_image # This might change if built by Cloud Build

  # Pass secrets as environment variables
  env_vars = {
    JWT_SECRET  = var.jwt_secret_value
    MONGODB_URI = var.mongodb_uri_value
    SECRET      = var.secret_value
  }
}

# Cloud Build Trigger
module "cloud_build_trigger" {
  source = "../../modules/cloud-build"

  project_id         = var.project_id
  location           = "global" # Triggers are often global
  trigger_name       = var.trigger_name # Value set in tfvars to match imported name
  description        = "Build and deploy to Cloud Run service pawashare-backend on push to \"^main$\"" # Match imported state
  service_account_id = var.cloud_build_service_account_id # e.g., projects/.../serviceAccounts/...
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  disabled           = false

  # Top-level substitutions matching the imported trigger
  substitutions = {
    "_AR_HOSTNAME"   = var.ar_hostname
    "_AR_PROJECT_ID" = var.project_id
    "_AR_REPOSITORY" = module.artifact_registry.repository_id # Use output from AR module
    "_DEPLOY_REGION" = var.region
    "_PLATFORM"      = "managed"
    "_SERVICE_NAME"  = module.cloud_run_backend.service_name # Use output from Cloud Run module
    # _TRIGGER_ID removed based on plan diff - it's available implicitly within build steps via $TRIGGER_ID
  }

  # Top-level tags matching the imported trigger
  tags = [
    "gcp-cloud-build-deploy-cloud-run",
    "gcp-cloud-build-deploy-cloud-run-managed",
    var.service_name, # Use service name variable
  ]

  # GitHub configuration matching the imported trigger
  github_config = {
    owner = var.github_owner
    name  = var.github_repo_name
    push = {
      branch = "^main$"
    }
  }

  # Build definition matching the imported trigger
  # Note: Using built-in vars like $REPO_NAME, $COMMIT_SHA, $BUILD_ID is standard in build steps
  # Revert to static values + built-in vars based on import state
  build_images = ["${var.ar_hostname}/${var.project_id}/${module.artifact_registry.repository_id}/$REPO_NAME/${module.cloud_run_backend.service_name}:$COMMIT_SHA"] 
  build_timeout = "600s" 
  # build_substitutions = {} # Remove explicit empty blocks
  # build_tags = []          # Remove explicit empty blocks

  build_options = { # Explicitly define options matching state
      logging             = "CLOUD_LOGGING_ONLY"
      substitution_option = "ALLOW_LOOSE"
      # dynamic_substitutions = false # This is default, usually omitted unless true
  }

  build_steps = [
    {
      id   = "Build"
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "--no-cache",
        "-t",
        # Revert to static values + built-in vars based on import state
        "${var.ar_hostname}/${var.project_id}/${module.artifact_registry.repository_id}/$REPO_NAME/${module.cloud_run_backend.service_name}:$COMMIT_SHA",
        "backend", # Assuming source code is in 'backend' subdir relative to repo root
        "-f",
        "backend/Dockerfile", # Assuming Dockerfile path
      ]
    },
    {
      id   = "Push"
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
         # Revert to static values + built-in vars based on import state
        "${var.ar_hostname}/${var.project_id}/${module.artifact_registry.repository_id}/$REPO_NAME/${module.cloud_run_backend.service_name}:$COMMIT_SHA",
      ]
    },
    {
      id         = "Deploy"
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
      entrypoint = "gcloud"
      args = [
        "run",
        "services",
        "update",
        module.cloud_run_backend.service_name, # Use output
        "--platform=managed",
         # Revert to static values + built-in vars based on import state
        "--image=${var.ar_hostname}/${var.project_id}/${module.artifact_registry.repository_id}/$REPO_NAME/${module.cloud_run_backend.service_name}:$COMMIT_SHA",
        # Revert to static trigger ID + built-in vars based on import state
        "--labels=managed-by=gcp-cloud-build-deploy-cloud-run,commit-sha=$COMMIT_SHA,gcb-build-id=$BUILD_ID,gcb-trigger-id=${var.trigger_id_substitution}", 
        "--region=${var.region}",
        "--quiet",
      ]
    }
  ]
}

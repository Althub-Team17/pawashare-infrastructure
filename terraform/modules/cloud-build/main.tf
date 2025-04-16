resource "google_cloudbuild_trigger" "main" {
  # Use module input variables
  project     = var.project_id
  name        = var.trigger_name
  description = var.description
  location    = var.location # Typically "global" for triggers
  disabled    = var.disabled
  include_build_logs = var.include_build_logs
  service_account = var.service_account_id # Pass the full ID: projects/.../serviceAccounts/...

  substitutions = var.substitutions
  tags          = var.tags

  dynamic "github" {
    # Only include github block if github variables are provided
    for_each = var.github_config != null ? [1] : []
    content {
      name  = var.github_config.name
      owner = var.github_config.owner
      push {
        branch       = lookup(var.github_config.push, "branch", null) # Use lookup for optional keys
        tag          = lookup(var.github_config.push, "tag", null)
        invert_regex = lookup(var.github_config.push, "invert_regex", false)
      }
      # Add pull_request block if needed
    }
  }

  # Assuming inline build definition for now, could also use filename
  build {
    images        = var.build_images # List of images to build/tag
    timeout       = var.build_timeout
    substitutions = var.build_substitutions # Explicitly empty map {} if needed based on state
    tags          = var.build_tags          # Explicitly empty list [] if needed based on state

    options {
      dynamic_substitutions = lookup(var.build_options, "dynamic_substitutions", false)
      logging               = lookup(var.build_options, "logging", "CLOUD_LOGGING_ONLY")
      substitution_option   = lookup(var.build_options, "substitution_option", "ALLOW_LOOSE")
      # Add other options like machine_type, disk_size_gb if needed
    }

    # Dynamically create step blocks from input list
    dynamic "step" {
      for_each = var.build_steps
      content {
        id         = lookup(step.value, "id", null)
        name       = step.value.name # Required
        entrypoint = lookup(step.value, "entrypoint", null)
        args       = lookup(step.value, "args", [])
        # Add other step attributes like dir, secret_env, timeout, wait_for if needed
      }
    }
  }
}

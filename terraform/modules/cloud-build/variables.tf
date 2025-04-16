variable "project_id" {
  description = "The GCP project ID where the trigger will be created."
  type        = string
}

variable "location" {
  description = "The location for the Cloud Build trigger (usually 'global')."
  type        = string
  default     = "global"
}

variable "trigger_name" {
  description = "The name for the Cloud Build trigger."
  type        = string
}

variable "description" {
  description = "Description for the Cloud Build trigger."
  type        = string
  default     = "Cloud Build Trigger"
}

variable "disabled" {
  description = "Whether the trigger should be disabled."
  type        = bool
  default     = false
}

variable "include_build_logs" {
  description = "Whether to include build logs with Cloud Build results."
  type        = string
  default     = "INCLUDE_BUILD_LOGS_WITH_STATUS" # Or "INCLUDE_BUILD_LOGS_UNSPECIFIED"
}

variable "service_account_id" {
  description = "The full service account ID (projects/.../serviceAccounts/...) to run the build as. If null, uses default Cloud Build SA."
  type        = string
  default     = null
}

variable "substitutions" {
  description = "Top-level substitutions map for the trigger."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Top-level tags list for the trigger."
  type        = list(string)
  default     = []
}

variable "github_config" {
  description = "Object defining the GitHub source repository configuration."
  type = object({
    owner = string
    name  = string
    push = optional(object({ # Make push optional
      branch       = optional(string)
      tag          = optional(string)
      invert_regex = optional(bool, false)
    }))
    # pull_request = optional(object({ ... })) # Add if needed
  })
  default = null # Make the whole github block optional
}

# Build Definition Variables (for inline build)
variable "build_images" {
  description = "List of images to build and push."
  type        = list(string)
  default     = []
}

variable "build_timeout" {
  description = "Time limit for the build execution (e.g., '600s')."
  type        = string
  default     = "600s"
}

variable "build_substitutions" {
  description = "Substitutions specific to the build block (usually empty if top-level is used)."
  type        = map(string)
  default     = {}
}

variable "build_tags" {
  description = "Tags specific to the build block (usually empty if top-level is used)."
  type        = list(string)
  default     = []
}

variable "build_options" {
  description = "Map of build options."
  type        = map(string)
  default = {
    logging             = "CLOUD_LOGGING_ONLY"
    substitution_option = "ALLOW_LOOSE"
  }
}

variable "build_steps" {
  description = "List of build step objects."
  type = list(object({
    id         = optional(string)
    name       = string
    entrypoint = optional(string)
    args       = optional(list(string))
    # Add other optional step attributes here if needed:
    # dir        = optional(string)
    # secret_env = optional(list(string))
    # timeout    = optional(string)
    # wait_for   = optional(list(string))
  }))
  default = []
}

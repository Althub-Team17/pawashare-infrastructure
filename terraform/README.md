# Terraform Configuration for PawaShare Backend Infrastructure

## Introduction

This Terraform configuration manages the core Google Cloud Platform (GCP) resources required for the PawaShare backend CI/CD workflow (as described in the main [Project Report](../report.md)). This includes:

*   **Google Artifact Registry:** A Docker repository to store container images.
*   **Google Cloud Run:** The service hosting the containerized backend application.
*   **Google Cloud Build Trigger:** Automates building and deploying the application to Cloud Run upon code changes in GitHub.

This setup uses a modular approach for better organization and reusability.

## Directory Structure

```
terraform/
├── modules/                # Reusable Terraform Modules
│   ├── artifact-registry/  # Manages Artifact Registry repository
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cloud-build/        # Manages Cloud Build trigger
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── cloud-run/          # Manages Cloud Run service
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── env/                    # Environment-specific Configurations
    └── dev/                # Development Environment
        ├── main.tf         # Root config for 'dev', calls modules
        ├── variables.tf    # Variable declarations for 'dev'
        └── terraform.tfvars # Variable values for 'dev' (incl. secrets, gitignored)
```

*   **`modules/`**: Contains reusable building blocks for specific resource types.
*   **`env/dev/`**: Defines the specific infrastructure deployment for the 'dev' environment by calling the modules and providing environment-specific values.

## Initial Provisioning vs. Ongoing Management

It's important to understand that this Terraform code manages infrastructure that was **initially created manually** in the GCP console and then **imported** into Terraform's control.

*   **Initial State:** The resources (Artifact Registry, Cloud Run, Cloud Build Trigger) already existed in GCP.
*   **Import Process:** We used `terraform import` to bring these existing resources under Terraform management without destroying and recreating them.
*   **Ongoing Management:** Now, this Terraform code is the source of truth. Any future changes to these resources (e.g., updating Cloud Run settings, modifying the build trigger) should be done by modifying this code and running `terraform apply`. **Do not make manual changes in the GCP console**, as they will drift from the Terraform configuration.

## Workflow Guide (For Junior Engineers)

Follow these steps to work with this Terraform configuration:

**1. Prerequisites:**
   *   Install Terraform: [Official Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
   *   Authenticate to GCP: Ensure your local environment is authenticated to the correct GCP project (`endless-phoenix-453318-h6`) with sufficient permissions. Common methods include:
      *   `gcloud auth application-default login`
      *   Setting the `GOOGLE_APPLICATION_CREDENTIALS` environment variable.

**2. Working Directory:**
   *   **Always run `terraform` commands from the environment directory:** `cd terraform/env/dev`

**3. Initialize Terraform:**
   *   Run: `terraform init`
   *   Purpose: Downloads the necessary GCP provider plugin and initializes the modules. You only need to run this once initially, or again if you add/remove modules or change provider versions.

**4. Plan Changes:**
   *   Run: `terraform plan`
   *   Purpose: Shows you what changes Terraform *would* make to your infrastructure if you were to apply the current configuration. It compares your `.tf` files against the last known state (`terraform.tfstate`) and the actual resources in GCP.
   *   Output: Look for `Plan: X to add, Y to change, Z to destroy.`
      *   `+ create`: New resource will be created.
      *   `~ update in-place`: Existing resource will be modified.
      *   `- destroy`: Existing resource will be deleted.
   *   **Review carefully!** Ensure the planned changes match your intentions.

**5. Apply Changes:**
   *   Run: `terraform apply`
   *   Purpose: Executes the changes outlined in the `terraform plan`. It will ask for confirmation before proceeding.
   *   **===> CRITICAL WARNING <===**
      *   After the initial import and refactoring, running `terraform plan` currently shows a persistent difference for the `module.cloud_build_trigger.google_cloudbuild_trigger.main` resource, specifically within its nested `build` block (related to `substitutions`, `tags`, `timeout`, and argument string formatting).
      *   **This difference is a known artifact of the import process and state representation.** It does **NOT** represent a necessary change to the actual cloud resource.
      *   **DO NOT run `terraform apply` solely based on this specific Cloud Build trigger difference.** Applying it will likely have no effect or could potentially cause unintended configuration drift due to provider quirks.
      *   Only run `terraform apply` when the plan shows changes you *intended* to make (e.g., updating the Cloud Run image variable, changing a description, adding a new resource). Always review the plan output carefully before confirming `apply`.

**6. Secrets Management:**
   *   Sensitive values (API keys, database URIs, etc.) are defined in `terraform/env/dev/terraform.tfvars`.
   *   **This file is intentionally excluded from Git version control** via the `.gitignore` file located at the root of the `DevOps` directory.
   *   **NEVER commit `terraform.tfvars` or `.tfstate` files to Git.**

## Access Control & Security Considerations

*   **GCP IAM Permissions:** The user or service account running Terraform needs appropriate IAM roles in GCP to manage the resources (e.g., Artifact Registry Admin, Cloud Run Admin, Cloud Build Editor). Follow the principle of least privilege – grant only the necessary permissions.
*   **Terraform State (`.tfstate`):** The `terraform.tfstate` file (created in `terraform/env/dev/`) records the mapping between your Terraform resources and the real-world objects. It can sometimes contain sensitive information in plain text.
    *   It is **critical** that state files are not committed to version control, which is handled by the `.gitignore` file.
    *   For team collaboration and enhanced security, consider configuring **Remote State** using a backend like Google Cloud Storage (GCS). This stores the state file securely in a shared location with locking capabilities.
*   **Version Control (Git):**
    *   Commit all `.tf` files (modules, environment configurations, variable definitions).
    *   **Do NOT commit `.tfvars` files containing secrets or `.tfstate` files.** Ensure `.gitignore` is configured correctly.
    *   Use feature branches for making changes to the Terraform code.
    *   Review Terraform changes carefully in Pull Requests before merging.

## Final Caution

Terraform is a powerful tool that directly manages your cloud infrastructure.
*   Always run `terraform plan` and review the output carefully before running `terraform apply`.
*   Be especially cautious with `terraform destroy`, as it will permanently delete the managed infrastructure.

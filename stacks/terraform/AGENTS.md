## Stack: Terraform

Detection markers: *.tf, .terraform.lock.hcl

- Detect package manager / build tool from project files; do not assume defaults.
- Run fmt and validate in modules that contain .tf files
- Prefer scripts defined in the repository over global tooling.

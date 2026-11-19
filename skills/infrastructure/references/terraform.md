# Terraform and OpenTofu: refactoring, import and drift

Read before renaming, moving or splitting resources or modules, importing existing resources or
reconciling drift. The commands are the same in OpenTofu (`tofu` in place of `terraform`).

## Contents
- Safe apply loop
- Renaming and moving without replacement
- Splitting state
- Importing existing resources
- Drift
- Destroy protection

## Safe apply loop

```bash
terraform fmt -check && terraform validate
terraform plan -out=tfplan
terraform show -no-color tfplan | grep -E 'will be destroyed|must be replaced|forces replacement'
terraform apply tfplan
```

Any destroy or replacement of a stateful resource stops the apply until someone has read why. Never use
`-auto-approve` against production except on a saved plan that was reviewed.

## Renaming and moving without replacement

Changing a resource address (rename, move into a module, switch `count` to `for_each`) makes Terraform
see one resource removed and another added. Declare the move instead:

```hcl
moved {
  from = aws_s3_bucket.logs
  to   = module.logging.aws_s3_bucket.this
}

moved {
  from = aws_instance.web[0]
  to   = aws_instance.web["primary"]
}
```

Then plan and require zero adds and destroys for those resources. Keep `moved` blocks for at least one
release so every environment and every module consumer passes through them. Prefer them to
`terraform state mv`, which is unreviewed and per-environment.

## Splitting state

Moving resources to a different state (for example, splitting a monolith root module):
1. Add `removed { from = ... lifecycle { destroy = false } }` in the old configuration and apply, so it
   forgets the resources without destroying them.
2. Add `import` blocks for them in the new configuration and apply.
3. Plan both and require no changes.

## Importing existing resources

Use `import` blocks so the import is reviewed like any other change:

```hcl
import {
  to = aws_s3_bucket.assets
  id = "example-assets-bucket"
}
```

`terraform plan -generate-config-out=generated.tf` drafts the resource. Clean it up (remove computed
attributes, add variables) and plan until it shows no changes before the first apply.

## Drift

- Run a scheduled `terraform plan -detailed-exitcode` (exit 2 means changes) and alert on drift.
- When drift appears, find out who changed what and why before deciding direction. Either codify the
  change or apply to revert it. Never "fix" drift with `ignore_changes` alone.

## Destroy protection

```hcl
lifecycle {
  prevent_destroy = true
}
```

On databases, buckets holding data, DNS zones and key stores. Also enable the provider's own deletion
protection (for example on managed databases), because `prevent_destroy` only guards against Terraform,
and is removed along with the resource block if someone deletes the whole block.

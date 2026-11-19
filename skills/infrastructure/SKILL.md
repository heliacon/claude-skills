---
name: infrastructure
description: Use when provisioning or changing servers, VMs, networks, DNS, IAM or cloud resources, writing Terraform, OpenTofu or Ansible, hardening Linux or SSH, planning backups, restores or capacity, and diagnosing a sick host. Not for pipeline YAML (use `ci-cd`) or deploys, rollouts and monitoring of an app (use `devops`).
license: MIT
---

# Infrastructure

This skill covers the layer an application runs on: hosts, networks, DNS, identity and cloud
resources, defined as code and kept healthy. Shipping the application onto it is the `devops` skill.
The pipeline that builds it is the `ci-cd` skill.

## The rules that matter most

1. **Everything is code, and code is the only way in.** No console clicks, no hand edits on a server.
   A host that cannot be rebuilt from the repository will be lost with everything on it.
2. **Read the plan before you apply.** Save the plan (`terraform plan -out=tfplan`), read every
   `destroy` and `forces replacement` line, then apply that exact file. A plan you did not read is a
   gamble with production.
3. **Never lock yourself out.** Before changing SSH, firewall or IAM rules that govern your own access,
   keep a second session open and test the new rule from a fresh connection before closing the old one.
4. **A backup is a restore you have run.** Untested backups are a hope. Schedule restore drills and
   record the time each one took.
5. **Least privilege, scoped by resource.** No wildcard actions or resources in IAM, no shared admin
   accounts, no service account broader than its job.
6. **Every production change has a rollback written before it starts.** Written during the incident it
   caused is too late.

## Infrastructure as code (Terraform and OpenTofu)

- Remote state with locking (an object store with a lock table, or a managed backend). Local state on
  one laptop is a single point of failure.
- **State holds secrets in plain text.** Encrypt the backend, restrict who can read it, never commit it.
- Pin provider and module versions in `versions.tf` and commit `.terraform.lock.hcl`.
- Layout: `main.tf`, `variables.tf` (with `validation` blocks), `outputs.tf`, `versions.tf`. Extract a
  module on the second real use, not the first.
- Separate state per environment and per blast radius. A change to DNS should not need a plan that also
  touches the database.
- Mark stateful resources (databases, buckets with data, DNS zones) with `prevent_destroy`.
- Run `terraform fmt -check` and `terraform validate` in CI, and post the plan on the pull request.
- Prefer replacing to patching: new image, new instance, cut over, remove old. OS security patches are
  the exception.
- Read `references/terraform.md` before renaming, moving or splitting resources or modules, importing
  existing resources or dealing with drift.

## Configuration management

- Idempotent: running it twice gives the same result as once. A task that always reports "changed" is
  a bug.
- Version-controlled, run from CI or a controlled host, tested in staging first.
- Install only what the service needs.
- In Ansible, give each task a clear name, use modules instead of `shell` wherever one exists, notify
  handlers on change and tag tasks for selective runs. Run with `--check --diff` before applying.

## Hardening

Apply before a host takes any workload. Read `references/linux-hardening.md` for the SSH, firewall,
user, kernel and CIS checklists, and the audit commands that prove each one.

## Backups

Default: 3-2-1. Three copies, on two kinds of storage, one offsite (and ideally one that the production
credentials cannot delete, so ransomware or a bad script cannot remove the backups too).

Retention default: daily for 7 days, weekly for 4 weeks, monthly for 12 months. Restore-test monthly, and
after any change to the backup job. Record the restore time: it is your real recovery time.

## Change management

Every production change has: a written procedure before it starts, a rollback, a staging run, a
maintenance window if it is risky and a log entry recording who, what, when, why and the outcome.
Runbook, incident and postmortem templates live in the `devops` skill's `references/incidents.md`.

## Monitoring baseline

Every host emits CPU, memory, disk and network metrics (node_exporter or equivalent), ships system and
auth logs to a central store. It alerts on disk at 80% (warning) and 90% (critical), failed systemd
units and certificate expiry within 14 days. Application-level alerting is the `devops` skill.

## Diagnosing a sick host

| Symptom | First commands |
|---|---|
| Disk full | `df -h`, `df -i` (inodes), `du -xsh /var/log/* \| sort -h`, `lsof +L1` (deleted but still open) |
| High CPU | `top`, `ps aux --sort=-%cpu \| head` |
| Memory pressure | `free -h`, `ps aux --sort=-%mem \| head`, `dmesg -T \| grep -i oom` |
| Service down | `systemctl status <unit>`, `journalctl -u <unit> -n 200 --no-pager` |
| Network | `ss -tlnp`, `ip addr`, `ip route`, `dig <name>`, `curl -v`, `nft list ruleset` |
| High load, low CPU | `iostat -x 1 5`, `vmstat 1 5` (load counts processes blocked on I/O) |

## Capacity

Baseline a week of CPU, memory, disk and network (average and p95) and project growth. Act at a
threshold, not at the limit: CPU 70% average, memory 80%, disk 70%. Review monthly for fast-growing
services, quarterly for stable ones and always before a planned traffic event. Keep the numbers in
`docs/capacity-plan.md`.

## Gotchas

- **Renaming a resource in Terraform destroys it.** Use a `moved` block. See `references/terraform.md`.
- **`count` over a list.** Removing the first item shifts every index and replaces the rest. Use
  `for_each` with stable keys.
- **`ignore_changes` hides drift** that someone made by hand. Use it only for fields another system
  legitimately owns, with a comment saying which.
- **Enabling a firewall before allowing SSH.** `ufw enable` with no SSH rule ends the session. Allow
  first, enable second, test from a new connection.
- **A long DNS TTL during a migration.** Clients keep the old answer for the full TTL. Lower it a full
  old-TTL period before the change, raise it after.
- **`noexec` on `/tmp`** breaks some installers and build tools that run scripts from there. Point them
  at another temp directory rather than dropping the hardening.
- **Disk "full" with space free.** Out of inodes, or a deleted log file still held open by a process.
- **Single points of failure** that are not machines: one person who knows the setup, one expiring
  domain or certificate on someone's personal card, one region.
- **Untagged resources.** Tag every resource with owner, environment and cost centre. Untagged cost is
  orphaned cost: idle instances, unattached volumes, forgotten environments.

## Verification

- `terraform plan` on the main branch shows no changes (no drift).
- Hardening audit output (Lynis score and findings, `sshd -T` output) saved with the change.
- Latest restore drill: date, data set, time taken and a check that the restored data is correct.
- An access test from a fresh session after any SSH, firewall or IAM change.

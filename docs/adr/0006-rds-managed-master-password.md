# ADR 0006: RDS Master Password Managed by AWS, Not Passed as a Variable

## Status
Accepted

## Context
The RDS instance needs a master password. The common approaches are:
pass it as a Terraform variable (plaintext in .tfvars, shell history,
and Terraform state), generate it with Terraform's `random_password`
resource and store it in Secrets Manager via a separate
`aws_secretsmanager_secret` resource, or let RDS generate and own it
directly via the `manage_master_user_password` argument on
`aws_db_instance`.

The application (Spring Boot) already needs to read a database
credential from somewhere at startup — it was always going to touch
Secrets Manager one way or another.

## Decision
Set `manage_master_user_password = true` on the RDS instance, with no
password variable declared anywhere in the module. AWS generates the
password itself and stores it directly in Secrets Manager, managed as
part of the RDS resource's own lifecycle.

## Consequences

**Positive:**
- The password never exists in plaintext anywhere this project
  controls — not in `.tfvars`, not in shell history, not typed by a
  human at any point
- One fewer resource to manage compared to the `random_password` +
  `aws_secretsmanager_secret` approach — AWS owns the secret's
  lifecycle (including rotation, if enabled later) alongside the
  database's own lifecycle
- The application already needs a Secrets Manager read at startup
  regardless of which approach was chosen, so this adds no new
  integration point

**Negative / trade-offs:**
- Less direct control over the secret's name, rotation schedule, or
  structure compared to managing it as a standalone Terraform resource
- The password is not visible anywhere for manual inspection without
  retrieving it from Secrets Manager explicitly (`aws secretsmanager
  get-secret-value`) — a deliberate trade-off, not an oversight, but
  worth knowing before expecting to find it in Terraform output or
  state

## Alternatives considered
- **Password as a Terraform variable:** rejected outright — plaintext
  secret in .tfvars and state is the exact thing this decision exists
  to avoid
- **`random_password` + standalone `aws_secretsmanager_secret`:**
  rejected — more resources to manage for no real benefit over letting
  RDS own the secret directly, given no rotation requirement exists
  yet for this project
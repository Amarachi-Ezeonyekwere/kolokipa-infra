# ADR 0009: tfsec Triage Policy and Accepted Infrastructure Risks

## Status
Accepted

## Context
tfsec scans the Terraform on every plan. The first scan of the full
environment reported 18 findings: 0 critical, 4 high, 3 medium and 11 low.
The scan runs with soft_fail while the project is being built, so findings
are reported without blocking the pipeline. A policy is needed so that every
finding is either fixed or consciously accepted, never silently ignored.

## Decision
Every CRITICAL and HIGH finding is fixed, or documented with an ignore
comment and a reason. MEDIUM and LOW findings are accepted for this
disposable dev environment, with reasons recorded here.

HIGH findings:
- ALB does not drop invalid headers: fixed (drop_invalid_header_fields = true).
- Public subnets auto-assign public IPs: fixed (map_public_ip_on_launch = false).
  The ALB receives its public addresses from the load balancer service
  regardless of this setting, tasks run in private subnets with no public IP,
  and nothing else launches into the public subnets.
- ALB is publicly exposed: accepted and annotated. The ALB is the internet
  entry point by design (see ADR 0003).
- Flow-log policy uses a wildcard: accepted and annotated. The wildcard covers
  the log streams inside one log group, the standard form of that permission.

MEDIUM findings, accepted:
- Short database backup retention and no deletion protection: the database
  holds disposable demo data and is recreated on every apply. Deletion
  protection would also block the destroy workflow.
- IAM database authentication: requires application changes to use short-lived
  tokens; password authentication via Secrets Manager is used instead.

LOW findings, accepted:
- Security group rules without descriptions: cosmetic, to be added.
- AWS-managed keys instead of customer-managed KMS keys for secrets, ECR and
  log groups: data is still encrypted at rest, and each customer-managed key
  adds a monthly cost and rotation duties.
- RDS Performance Insights not enabled: no performance baseline needed yet.

Risks that tfsec does not report, also accepted for now:
- The ALB listens on HTTP only because there is no custom domain, so no ACM
  certificate (see ADR 0003). Logins and tokens cross the internet unencrypted.
- The Terraform runner role has AdministratorAccess.

## Consequences
- The pipeline stays non-blocking while the project is built.
- When soft_fail is switched to false, every remaining finding needs either a
  fix or an ignore annotation that references this ADR.
- Before any persistent or production environment: enable HTTPS with a custom
  domain, scope the Terraform runner role to least privilege, enable backup
  retention and deletion protection, and revisit the customer-managed keys.

## Alternatives considered
- Fix every finding now: rejected. The medium and low items add cost or effort
  with no benefit for a disposable demo environment.
- Ignore all findings: rejected. It leaves no record of which risks were
  understood and which were missed.

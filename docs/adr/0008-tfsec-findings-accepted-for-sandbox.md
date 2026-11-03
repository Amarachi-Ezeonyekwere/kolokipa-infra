# ADR 0008: tfsec Findings Accepted for the Sandbox Environment

## Status
Accepted

## Context
The pipeline runs tfsec against the Terraform code. The first scan
reported 26 findings (6 critical, 4 high, 3 medium, 13 low). This is a
single-developer sandbox with no production data, built under free-tier
and time constraints, so findings are triaged by risk and cost rather
than all fixed.

## Decision
Fix critical findings that are cheap to fix, document the intentional
ones, and defer the rest.

Fixed:
- ALB, VPC endpoint and RDS security group egress narrowed to the VPC
  (or removed)

Intentional (suppressed in code with tfsec:ignore):
- ALB inbound from the internet: it is the public entry point
- ALB HTTP listener: no domain means no ACM certificate (see ADR-0003)
- ECS tasks egress: needed for the S3 gateway endpoint; the private
  route table has no internet route, so reach is limited to VPC endpoints

Deferred:
- HIGH: ALB public by design; drop_invalid_header_fields not set (one-line
  fix); flow-log IAM policy uses a log-stream wildcard scoped to a single
  log group; public subnets assign public IPs although nothing launches
  instances there
- MEDIUM: RDS backup retention, IAM database authentication and
  deletion protection (a dev toggle by design), none required for
  sandbox data
- LOW: missing security group rule descriptions; customer-managed KMS
  keys for ECR and CloudWatch log groups (a dedicated key adds a
  monthly charge; AWS-managed encryption stays on); RDS Performance
  Insights

## Consequences
**Positive:**
- Effort goes to the findings that matter most for a public entry point
- Every accepted risk is written down with a reason

**Negative / trade-offs:**
- The security gate is advisory (soft_fail) until the deferred items are
  cleared or a severity threshold is set
- Deferred items would need fixing before any production use

## Alternatives considered
- Fix all 26 findings: rejected as disproportionate for a sandbox
- Disable tfsec: rejected, since visible findings are the point of the gate
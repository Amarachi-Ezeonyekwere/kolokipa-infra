# ADR 0001: VPC Endpoints over NAT Gateway for Private Subnet Egress

## Status
Accepted

## Context
ECS Fargate tasks running in private subnets need to reach AWS services
(ECR, CloudWatch Logs, Secrets Manager) to start up, log, and resolve
database credentials. Two options provide this: a NAT Gateway (routes
all outbound traffic through a public IP) or VPC Endpoints (private,
AWS-internal connections to specific services via PrivateLink /
S3 gateway).

The application currently has no dependency on any third-party API,
SaaS service, or external endpoint outside the AWS ecosystem. Fargate
is serverless, so the operator does not patch or update the underlying
host OS — internet access for OS-level updates is not a requirement.

## Decision
Use VPC Endpoints instead of a NAT Gateway:
- Gateway endpoint: S3 (free — carries ECR image layer traffic)
- Interface endpoints: ecr.api, ecr.dkr, logs, secretsmanager
- Deployed in both availability zones (no single point of failure)

## Consequences

**Positive:**
- No NAT Gateway hourly cost (~$0.045/hr avoided)
- Lower per-GB data-processing cost on interface endpoints vs. NAT
- S3 gateway endpoint carries the highest-volume traffic (image
  layers) at zero cost
- Traffic never leaves the AWS network — smaller attack surface than
  routing through a NAT's public IP

**Negative / trade-offs:**
- If a future feature requires calling a third-party API (payment
  gateway, SMS/email provider) with no AWS PrivateLink support, this
  decision must be revisited — VPC endpoints only work for
  AWS-published services
- Four interface endpoints across two AZs have a real (if modest)
  hourly cost — not literally free, just cheaper than NAT here
- One more piece of infrastructure to provision and reason about
  per environment, vs. a single NAT Gateway

## Alternatives considered
- **NAT Gateway (single, one AZ):** rejected — solves for internet
  egress the workload doesn't currently need, at a higher steady-state
  cost than the endpoints actually required
- **NAT Gateway (per-AZ, fully HA):** rejected for the same reason,
  at even higher cost
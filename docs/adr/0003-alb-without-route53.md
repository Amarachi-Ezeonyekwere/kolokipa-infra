# ADR 0003: Application Load Balancer without Route 53 / Custom Domain

## Status
Accepted

## Context
The application needs a stable entry point in front of the ECS
Fargate services running in private subnets. A standard production
setup pairs an ALB with a Route 53 hosted zone and a custom domain
(plus an ACM certificate for HTTPS on that domain).

Route 53 hosted zones are not covered by the AWS Free Tier — each
hosted zone has a flat monthly charge regardless of traffic. A custom
domain also has an ongoing registration cost. This project is a
self-funded portfolio piece built on a free-tier account, with no
budget allocated for either.

## Decision
Provision an ALB in the public subnets, with a security group
allowing inbound HTTP from the internet and outbound to the ECS
task security group only. Do not provision Route 53 or a custom
domain. The application is reached via the ALB's AWS-assigned DNS
name (`<name>-<id>.<region>.elb.amazonaws.com`).

## Consequences

**Positive:**
- No Route 53 hosted zone cost, no domain registration cost
- Still demonstrates the correct pattern — public-subnet load
  balancer terminating traffic in front of private-subnet compute —
  which is the architecturally significant part of this decision
- The ALB’s AWS-assigned DNS name cannot carry an ACM certificate, 
  so HTTPS requires a domain you control.This is a real limitation, noted below.

**Negative / trade-offs:**
- No custom domain — the AWS-generated hostname is long and
  unbranded, acceptable for a portfolio demo, not for a real product
- Without a domain, ACM cannot issue a certificate for the ALB
  listener, so the public-facing listener runs HTTP only unless a
  self-signed or ACM-imported cert is used — a known, accepted gap for
  this stage of the project
- If a custom domain is added later, this decision gets revisited —
  Route 53 + ACM + an HTTPS listener would then be a small, additive
  change on top of the existing ALB, not a redesign

## Alternatives considered
- **ALB + Route 53 + ACM (full production pattern):** rejected for
  this project due to Route 53's flat cost with no free tier and the
  added cost of domain registration
- **CloudFront in front of the ALB:** rejected — adds complexity and
  its own cost for a benefit (CDN caching, edge TLS) this project
  doesn't currently need
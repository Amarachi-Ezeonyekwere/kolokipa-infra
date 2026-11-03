# ADR 0004: Single ALB with Path-Based Routing over Two ALBs

## Status
Accepted

## Context
The application has two backend services behind the load balancer —
Next.js (frontend) and Spring Boot (API). Two designs support this:
one ALB with path-based listener rules routing `/` and `/api/*` to
different target groups, or two independent ALBs, one per service.

ALB has no AWS Free Tier coverage — every ALB incurs an hourly charge
plus LCU usage from creation, regardless of traffic.

## Decision
Use a single ALB with one listener and a path-based listener rule
routing `/api/*` to the Spring Boot target group, with Next.js as the
listener's default action.

## Consequences

**Positive:**
- Roughly half the ongoing ALB cost compared to two ALBs
- Path-based routing in front of two services is a standard,
  production-legitimate pattern — not a compromise pretending to be
  a full design
- One DNS name for the whole application, simpler for a portfolio demo

**Negative / trade-offs:**
- Shared blast radius — a listener misconfiguration can affect both
  services, where two ALBs would isolate that risk
- Both services share the same ALB's connection/LCU capacity, which
  matters at scale but not at this project's traffic level

## Alternatives considered
- **Two ALBs, one per service:** rejected — doubles a cost that has
  no free-tier offset, for isolation benefits this project's scale
  doesn't need
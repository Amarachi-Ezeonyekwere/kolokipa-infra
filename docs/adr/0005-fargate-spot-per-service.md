# ADR 0005: Register Both FARGATE and FARGATE_SPOT, Decide Usage Per Service

## Status
Accepted

## Context
ECS Fargate tasks can run on standard Fargate (full price, no
interruption risk) or Fargate Spot (~70% cheaper, but AWS can reclaim
the capacity with roughly 2 minutes' notice). The cluster itself
decides which capacity providers are *available*; each service
decides how it actually uses them via its own capacity provider
strategy.

The initial instinct was to split by service category — frontend
(Next.js) on Spot, backend (Spring Boot) on standard — on the
assumption that "backend" implies state that can't tolerate
interruption. On reflection, that's the wrong axis: Spot safety
depends on whether a service is stateless (no in-memory session data,
no in-flight work that can't be resumed elsewhere), not on whether it
happens to be labeled frontend or backend. RDS is unaffected by this
decision entirely — Fargate Spot only applies to ECS compute, not to
the database.

## Decision
Register both FARGATE and FARGATE_SPOT as available capacity
providers on the cluster, with a default_capacity_provider_strategy of
100% standard FARGATE. The actual Spot-vs-standard choice is made
per service, at the point each ECS service is defined, based on
whether that specific service is verified stateless — not assumed
from its role in the architecture.

## Consequences

**Positive:**
- The cluster-level default is the safe one — a service that doesn't
  explicitly opt into Spot never accidentally runs on it
- Keeps the door open to running Spring Boot on Spot later if/once
  it's confirmed stateless, without any change to this module
- Forces a real, statelessness-based justification for each service's
  strategy rather than a category-based assumption

**Negative / trade-offs:**
- No cost savings are realized until at least one service explicitly
  opts into Spot — registering the capacity provider alone does
  nothing for cost by itself
- The decision has to be made and justified again at each service's
  definition, rather than being settled once here

## Alternatives considered
- **Frontend on Spot, backend on standard, decided at the cluster
  level:** rejected — conflates architectural role with interruption
  tolerance, which are not the same thing
- **Everything on standard Fargate, no Spot at all:** rejected —
  gives up meaningful cost savings for a dev/portfolio environment
  where at least the frontend is very likely stateless
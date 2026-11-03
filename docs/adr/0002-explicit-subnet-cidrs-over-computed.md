# ADR 0002: Explicit Subnet CIDR Lists over Computed Subnetting

## Status
Accepted

## Context
Subnets can be addressed two ways in Terraform: computed from the VPC
CIDR using cidrsubnet(), or passed in explicitly as a list of CIDR
blocks per tier (public, private-app, private-db). This module is
built to be cloned by other teams for unrelated workloads (e.g. a
hospital application), not just KoloKipa.

## Decision
Subnet CIDRs are passed as explicit variables (lists of strings) in
terraform.tfvars, one entry per availability zone per tier. The module
performs no CIDR arithmetic internally.

## Consequences

**Positive:**
- The full address plan is visible directly in terraform.tfvars —
  no need to trace a cidrsubnet() call to know what a subnet's range
  actually is
- A team cloning this module defines their own address plan without
  needing to understand or trust this module's internal splitting logic
- Reduces the chance of an unintentional CIDR overlap being hidden
  behind a function call

**Negative / trade-offs:**
- More typing up front — every subnet's CIDR is written out by hand
  rather than derived
- No built-in guarantee of non-overlapping ranges; the caller is
  responsible for planning a valid address scheme before filling in
  terraform.tfvars

## Alternatives considered
- **cidrsubnet()-based computed subnetting:** rejected — optimizes for
  less typing at the cost of transparency, which works against this
  module's reusability goal
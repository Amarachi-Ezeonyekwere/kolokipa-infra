# ADR 0007: GitHub OIDC Federation over Static IAM Access Keys

## Status
Accepted

## Context
The application repo's CI pipeline needs AWS credentials to push
images to ECR and deploy to ECS. The common approach is generating a
long-lived IAM access key/secret pair and storing it as a GitHub
secret. The alternative is OIDC federation, where GitHub issues a
short-lived signed token per workflow run, and AWS exchanges it for
temporary credentials scoped to that run.

## Decision
Use OIDC federation via aws_iam_openid_connect_provider, with the
IAM role's trust policy scoped to the specific repo and branch
(repo:<org>/<repo>:ref:refs/heads/main). No static access keys are
generated or stored anywhere for CI use.

## Consequences

**Positive:**
- No long-lived secret exists to leak — credentials are minutes-long
  and generated fresh per workflow run
- The trust policy's sub condition restricts which repo and branch
  can assume the role; a PR build never gets deploy-capable credentials
- No manual key rotation required — there's nothing to rotate

**Negative / trade-offs:**
- More setup complexity than pasting two secrets into GitHub — the
  OIDC provider, trust policy, and scoped permissions policy all have
  to be configured correctly together
- Debugging a trust policy mismatch (wrong org/repo/branch in the sub
  condition) produces a generic "not authorized to perform
  AssumeRoleWithWebIdentity" error with no indication of which part
  of the condition failed

## Alternatives considered
- **Static IAM access keys as GitHub secrets:** rejected — a leaked
  long-lived key has no natural expiration and requires manual
  detection and revocation
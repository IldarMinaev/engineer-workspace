---
applyTo: "**"
---

## Troubleshooting: MUST follow the skill chain

MANDATORY SEQUENCE for any k8s/PostgreSQL issue:
1. `troubleshooting-triage` — maps symptom to skill sequence
2. `kubernetes-context` — verify cluster/namespace/RBAC
3. Follow triage-recommended skills
4. Only use raw kubectl/psql for gaps the skills don't cover

The FIRST tool call after kubernetes-context should be a Skill invocation, not a kubectl command. If you catch yourself running raw psql/kubectl for investigation (not targeted follow-up), STOP and invoke the appropriate skill instead. Treat the skill chain as mandatory dispatch, not a suggestion.

### Dynamic skill discovery

Do NOT hard-code skill names or mappings — not even names returned by `troubleshooting-triage`. Triage output is a hint, not a dispatch table. Before invoking any skill (other than `troubleshooting-triage` and `kubernetes-context`), you MUST discover it dynamically via any of these valid methods:
1. Glob `.claude/skills/*/SKILL.md` and read YAML frontmatter to match skill description.
2. Use the `common-troubleshooting` routing table to select the appropriate skill.
3. Match against skill descriptions visible in system-reminder skill listings.

The rule guards against blindly guessing skill names — selecting from structured sources (frontmatter, routing tables, system-reminder descriptions) is valid discovery.

Raw kubectl/psql is ONLY for targeted follow-up after a skill has identified a specific area needing deeper inspection.

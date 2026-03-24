# Memory Guidelines

## Rules

- Always use the `agent-memory` skill (`/agent-memory`) for saving, recalling, and organizing memories
- Do not write directly to the auto memory directory (`memory/`); use it only as an index pointing to the agent-memory skill
- Follow the agent-memory skill's folder structure and frontmatter format when saving

## Saving Plans After Approval

After the user approves a plan (ExitPlanMode approved), save the plan content using the `/agent-memory` skill:

- Scope: the current repository name
- Directory name: `<YYYY-MM-DD>_<task-description>-plan`
- File name: `plan.md`
- Include in the memory: task goal, implementation approach, key files, and verification steps
- If a related plan memory already exists, update it instead of creating a new one

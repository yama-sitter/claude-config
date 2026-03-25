---
name: agent-memory
description: |
  Use this skill when the user asks to save, remember, recall, or organize memories.
  Triggers on: 'remember this', 'save this', 'note this', 'what did we discuss about...', 'check your notes', 'clean up memories'.
  Also use proactively when discovering valuable findings worth preserving.
  Subcommands:
    - `save [description]`: Run Save Workflow to persist a memory
    - `search [query]`: Run Search Workflow to find existing memories
    - (no args): Infer intent from conversation context
---

# Agent Memory

A persistent memory space for storing knowledge that survives across conversations.

**Location:** `~/.agent-memory/`

## Argument Routing

| Args                           | Action                                                                        |
| ------------------------------ | ----------------------------------------------------------------------------- |
| `save` or `save <description>` | Go to **Save Workflow** — use `<description>` as the topic hint               |
| `search <query>`               | Go to **Search Workflow** — use `<query>` as the search keyword               |
| `search` (no query)            | Go to **Search Workflow** — interactively narrow down by scope → topic        |
| (empty / no args)              | Infer whether to save or search from conversation context (existing behavior) |

## Save Workflow

1. **Determine content**: Identify what to save from the conversation context or `<description>` argument
2. **Expand context from sources**: If the content being saved builds upon, extends, or references an existing memory (e.g., a recalled memo from earlier in the conversation), do both:
   - **Embed context**: Incorporate the necessary background from the source memory so the new memo is fully understandable on its own. A reader with no prior knowledge must be able to follow the content without reading the source memo. Do not merely summarize — include the specific facts, decisions, and context that the new content depends on
   - **Link source**: Add all source memory paths to the `related` field in frontmatter (e.g., `related: [..., scope/date_topic/file.md]`)
3. **Choose scope and path**: Select scope (repository name or `general`) and build the path:
   `<scope>/<YYYY-MM-DD>_<descriptive-name>/<filename>.md`
   - Use `date +%Y-%m-%d` for the current date
4. **Duplicate check**: Search existing memories to avoid redundancy
   ```bash
   rg "^summary:.*<keyword>" ~/.agent-memory/ --no-ignore --hidden -i
   ```
   - If a closely related memory exists, update it instead of creating a new file
5. **Write file**: Write the file with required frontmatter (Write tool creates parent directories automatically, so mkdir is not needed)
   - Check if file exists before writing to avoid accidental overwrites
6. **Confirm**: After saving, display the saved path and summary to the user

## Search Workflow

### With query: `search <query>`

1. **Scope narrowing** (optional): If the relevant scope is known, narrow search path
2. **Staged search** — stop when useful results are found:
   - Stage 1: `rg "^summary:.*<keyword>" ~/.agent-memory/ --no-ignore --hidden -i`
   - Stage 2: `rg "^tags:.*<keyword>" ~/.agent-memory/ --no-ignore --hidden -i`
   - Stage 3: `rg "<keyword>" ~/.agent-memory/ --no-ignore --hidden -i`
3. **Present results**: Display as a numbered list with summaries
4. **Show detail**: Display the full content of the user's selected memory

### Without query: `search`

1. **List scopes**: Run `ls ~/.agent-memory/` to retrieve the list of scopes
   - If there is only one scope, skip and auto-select it
   - If there are multiple scopes, use AskUserQuestion to let the user choose
2. **List topics**: Display the directory listing (date + topic name) within the selected scope
   - Use AskUserQuestion to let the user choose a topic
3. **Show detail**: Read and display the full content of the files in the selected topic
   - If there are multiple files, show the file list and let the user choose

### Post-search

After the **Show detail** step, display the full path of the selected file. If `pbcopy` is available, also copy the path to the clipboard. If copying is not possible, display the path only.

**Note:** Memory files are gitignored — always use `--no-ignore --hidden` flags with ripgrep.

## Reference

### Folder Structure

Organize memories using the following directory convention:

`<scope>/<YYYY-MM-DD>_<descriptive-name>/<filename>.md`

- **scope**: Repository name (e.g. `taimee-rails-api`) or `general` for cross-project / non-repository-specific memories
- **YYYY-MM-DD**: Date the memory was created (on the directory name)
- **descriptive-name**: A concise name describing the topic (kebab-case)
- **filename**: A name describing the content of the file (e.g. `finding.md`, `progress.md`, `design.md`)

Guidelines:

- Use kebab-case for all folder and file names
- Consolidate or reorganize as the knowledge base evolves

Example:

```text
taimee-rails-api/
├── 2026-02-06_suspended-company-email-registration/
│   └── finding.md
└── 2026-02-10_bulk-export-performance-issue/
    └── finding.md
general/
└── 2026-01-20_docker-compose-networking-tips/
    └── finding.md
```

### Frontmatter

All memories must include frontmatter with a `summary` field. The summary should be concise enough to determine whether to read the full content.

**Summary is the decision point**: Agents scan summaries via `rg "^summary:"` to decide which memories to read in full. Write summaries that contain enough context to make this decision - what the memory is about, the key problem or topic, and why it matters.

**Required:**

```yaml
---
summary: "1-2 line description of what this memory contains"
created: 2025-01-15 # YYYY-MM-DD format
---
```

**Optional:**

```yaml
---
summary: "Worker thread memory leak during large file processing - cause and solution"
created: 2025-01-15
updated: 2025-01-20
tags: [performance, worker, memory-leak]
related:
  [
    src/core/file/fileProcessor.ts,
    general/2026-01-10_worker-architecture/design.md,
  ]
---
```

### Proactive Usage

Save memories when you discover something worth preserving:

- Research findings that took effort to uncover
- Non-obvious patterns or gotchas in the codebase
- Solutions to tricky problems
- Architectural decisions and their rationale
- In-progress work that may be resumed later

Check memories when starting related work:

- Before investigating a problem area
- When working on a feature you've touched before
- When resuming work after a conversation break

### Maintain

- **Update**: When information changes, update the content and add `updated` field to frontmatter
- **Delete**: Remove memories that are no longer relevant
  ```bash
  trash ~/.agent-memory/category-name/filename.md
  # Remove empty category folders
  rmdir ~/.agent-memory/category-name/ 2>/dev/null || true
  ```
- **Consolidate**: Merge related memories when they grow
- **Reorganize**: Move memories to better-fitting categories as the knowledge base evolves

Organize memories when needed:

- Consolidate scattered memories on the same topic
- Remove outdated or superseded information

### Guidelines

1. **Write for resumption**: Memories exist to resume work later. Capture all key points needed to continue without losing context - decisions made, reasons why, current state, and next steps.
2. **Write self-contained notes**: Include full context so the reader needs no prior knowledge to understand and act on the content
3. **Keep summaries decisive**: Reading the summary should tell you if you need the details
4. **Stay current**: Update or delete outdated information
5. **Be practical**: Save what's actually useful, not everything
6. **One topic per file**: Split memories by concept (e.g., separate "design decisions" and
   "pitfalls" rather than combining into one large file). This makes summaries more precise
   and searchable.
7. **Use `related` for discoverability**: Always include directory/file paths in the `related`
   field. This enables reverse lookup by path: `rg "^related:.*keyword" ~/.agent-memory/`

### Content Reference

When writing detailed memories, consider including:

- **Context**: Goal, background, constraints
- **State**: What's done, in progress, or blocked
- **Details**: Key files, commands, code snippets
- **Next steps**: What to do next, open questions

Not all memories need all sections - use what's relevant.

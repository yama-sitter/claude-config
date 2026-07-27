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

Content composition and file writing are delegated to a subagent to keep Write tool output out of the main conversation context. The main agent handles extraction and decision-making; the subagent handles formatting and persistence.

1. **Determine what to save**: Identify what to save from the conversation context or `<description>` argument. Extract:
   - Scope (repository name or `general`), topic name, and filename
   - Frontmatter fields: `summary`, `tags`, `related` paths
   - Source memory paths (if extending an existing memory)
   - **Content key points** — structured bullet points covering:
     - Core facts, decisions, and their rationale (why)
     - Specific file paths, function names, and commands
     - Constraints, trade-offs, and open questions
     - Current state and next steps (if applicable)
     - Tables, numerical data, aggregated results, and query outputs MUST be included verbatim in Markdown table or code block format. NEVER convert them to bullet points, summarize, abbreviate, round, or omit rows.
   - **Self-containment check**: If Content Key Points reference any ID/symbol (e.g. U1, S-3, RQ3, X-2, i-1, Y-a) without inline body text, expand each ID to include its body text. NEVER pass ID-only references to the subagent — the subagent has no access to the originating conversation.
     - Scope: research/analysis/test-plan custom IDs only (e.g. `U\d+`, `S-?\d+`, `RQ\d+`, `X-?\d+`, `i-?\d+`, `Y-?\w+`). Excluded: code identifiers, file paths, external IDs (Notion/GitHub/Linear — cite URL instead).
   - Use `date +%Y-%m-%d` for the current date
2. **Duplicate check**: Search existing memories to avoid redundancy

   ```bash
   rg "^summary:.*<keyword>" ~/.agent-memory/ --no-ignore --hidden -i
   ```

   - If a closely related memory exists, decide whether to update it or create a new file (ask the user if unclear)
   - Pass `mode: new` or `mode: update` (with the existing file path) to Step 3

3. **Delegate to subagent**: Launch a `general-purpose` subagent via the Agent tool with the following prompt template. Replace `{placeholders}` with actual values from Steps 1-2.

   ```
   You are a memory writer agent for the agent-memory system.

   ## Save Parameters
   - Path: {absolute path to ~/.agent-memory/<scope>/<YYYY-MM-DD>_<topic>/<filename>.md}
   - Mode: {new | update}
   - Source memories to reference: {paths or "none"}

   ## Frontmatter
   summary: "{summary}"
   created: {YYYY-MM-DD}
   tags: [{tags}]
   related: [{related paths}]

   ## Content Key Points
   {structured key points extracted in Step 1}

   ## Quality Guidelines
   - Self-contained: a reader with no prior knowledge must understand the note
   - Write for resumption: include decisions, rationale, current state, next steps
   - Keep one topic per file
   - NEVER summarize, round, or omit any tables, numerical data, or query outputs from Content Key Points. Copy them exactly as provided — the raw data is the value.
   - NEVER write ID-only references (e.g. "U11, U13" without their body text). If the Content Key Points include such ID-only references without body text, return `status: failure` with `reason: "ID references lack body text — main agent must re-extract"`. The subagent has no access to the originating conversation and cannot resolve them.

   ## Instructions
   1. If source memories are specified, read them and embed necessary context into the note
   2. If mode is "update", read the existing file first and incorporate its content
   3. Compose the full markdown file: frontmatter + expanded prose from the key points
   4. Write the file (Write tool creates parent directories automatically)
   5. Return ONLY: status (success | failure), path, summary, reason (if failure)
   ```

4. **Confirm**: Display the result based on the subagent's return:
   - `success`: display the saved path and summary to the user
   - `failure`: display the error reason and suggest falling back to a direct Write

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

### Saving Plans

Do not automatically save plans to agent-memory. Save only when the user explicitly instructs it.

When instructed:

- Scope: the current repository name
- Directory name: `<YYYY-MM-DD>_<task-description>-plan`
- File name: `plan.md`
- Include: task goal, implementation approach, key files, verification steps
- If a related plan memory already exists, update it instead of creating a new one

### Content Reference

When writing detailed memories, consider including:

- **Context**: Goal, background, constraints
- **State**: What's done, in progress, or blocked
- **Details**: Key files, commands, code snippets
- **Next steps**: What to do next, open questions

Not all memories need all sections - use what's relevant.

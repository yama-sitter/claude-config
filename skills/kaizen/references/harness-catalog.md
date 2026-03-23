# Harness Catalog — Improvement Target Selection Guide

Reference for kaizen skill subagents to read before analysis.
Guides selection of the optimal improvement target based on the nature of the failure, and ensures correct formatting during implementation.

## 1. Target Selection Flow

Before generating improvement ideas, follow this flow to determine the optimal target.
Higher targets are more deterministic and more effective at preventing recurrence (Design Principle P1: Tooling > Prompting).

```
Can this failure be deterministically blocked/verified?
  → Yes → hooks (PreToolUse: exit 2 to block / PostToolUse: auto-verify)
  → No ↓
Should the operation be physically prohibited?
  → Yes → permissions (deny)
  → No ↓
Is process structuring (multi-step workflow) needed?
  → Yes → skills
  → No ↓
Should it apply globally, or is it project-specific?
  → Global → rules/
  → Project-specific → CLAUDE.md
```

## 2. Target Characteristics

| Target | Enforcement | Scope | Strengths | Limitations |
|---|---|---|---|---|
| hooks (settings.json) | Deterministic | Global | Auto-intervenes before/after tool execution. Can block, modify, or verify | Limited to conditions expressible in shell scripts. Complex judgment is difficult |
| permissions (settings.json) | Deterministic | Global | Physically allow/deny operations via glob patterns | Coarse-grained. Conditional permissions not possible |
| skills (~/.claude/skills/) | Workflow | Global | Structures multi-step procedures. Can insert confirmation gates | Requires explicit user invocation |
| rules/ (~/.claude/rules/) | Prompt instruction | Global | Always loaded, applies to all sessions | LLM may ignore. Probabilistic |
| CLAUDE.md | Prompt instruction | Project | Can describe project-specific instructions | LLM may ignore. Probabilistic |
| agent-memory | Knowledge persistence | Per-scope | Retains knowledge across sessions | Not referenced if search doesn't find it |

## 3. Failure Pattern → Target Mapping

| Failure Pattern | Recommended Target | Rationale |
|---|---|---|
| Execution of dangerous commands (rm -rf, force push, etc.) | hooks (PreToolUse, exit 2) | Can deterministically block before execution |
| Post-operation verification gaps (tests not run, lint not run, etc.) | hooks (PostToolUse) | Can force automatic verification after operation |
| Execution of operations that should not be permitted | permissions (deny) | Physically prohibit via glob pattern |
| Workflow step omissions (forgotten reviews, skipped confirmations, etc.) | skills | Structure procedures and insert confirmation gates |
| Repeated judgment errors (naming conventions, coding standards, etc.) | rules/ | Always loaded, applies to all sessions |
| Project-specific judgment errors (architecture, file placement, etc.) | CLAUDE.md | Project-scoped instructions |
| Cross-session knowledge loss (forgetting prior decisions, etc.) | agent-memory | Persist as searchable memory |

## 4. Implementation Templates

### hooks (settings.json)

**Exit code semantics (Design Principle P5: use precisely):**
- `exit 0` = Allow (hook output is ignored)
- `exit 2` = **Block** (abort operation, display hook's stdout to Claude)
- `exit 1` = **Warning only** (operation still executes! Cannot be used for blocking)

**PreToolUse hook (block before operation):**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | jq -r '.command' | grep -qE '<dangerous-pattern>'; then echo '<block-reason>'; exit 2; fi; exit 0"
          }
        ]
      }
    ]
  }
}
```

**PostToolUse hook (auto-verify after operation):**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "<verification-command>"
          }
        ]
      }
    ]
  }
}
```

**Notes:**
- `matcher` specifies the tool name: `Bash`, `Write`, `Edit`, `Read`, etc.
- `$CLAUDE_TOOL_INPUT` references tool input JSON (PreToolUse)
- `$CLAUDE_TOOL_OUTPUT` references tool output (PostToolUse)
- Multiple hooks can be specified as an array

### CLAUDE.md / rules/ (Design Principle P3: 5-Principle Checklist)

Follow these 5 principles when writing rules:

1. **Start with NEVER/ALWAYS** — Be definitive, not vague "should"
2. **Lead with the reason** — State why this rule is needed first
3. **Include concrete examples** — Show good/bad examples, not just abstract instructions
4. **One point per block** — Don't cram multiple instructions into one rule
5. **Prefer bullet points** — Use bullet points, not prose

**Template:**

```markdown
## [Section Name]

- NEVER [prohibited action]. Reason: [why prohibited]
  - Bad: `[specific bad example]`
  - Good: `[specific good example]`
```

**rules/ file placement:**
- File name: `~/.claude/rules/<topic>.md`
- One topic per file
- For quality standards that should always apply

### skills (~/.claude/skills/)

```yaml
---
name: skill-name
description: |
  Skill description.
  Use when: when to use.
  Do not use when: when not to use.
user-invocable: true
---
```

### permissions (settings.json)

```json
{
  "permissions": {
    "allow": ["Bash(npm *)"],
    "deny": ["Bash(sudo *)"],
    "ask": ["Bash(rm *)"]
  }
}
```

- `allow`: Auto-permit (no confirmation)
- `deny`: Auto-reject (cannot execute)
- `ask`: Prompt user each time
- Glob pattern support: `*` is wildcard

## 5. Anti-Patterns

| Anti-Pattern | Why It's Problematic | Correct Approach |
|---|---|---|
| Writing in CLAUDE.md/rules what hooks could prevent | Prompt instructions may be ignored by LLM. Use deterministic blocking if possible | hooks (PreToolUse, exit 2) |
| Using exit 1 thinking it blocks | exit 1 is warning-only; the operation still executes | Use exit 2 |
| Cramming multiple instructions into one rule | Increases chance LLM overlooks some parts | Split into one point per block |
| Adding new rules that duplicate existing ones | Rules bloat, contradictions and noise increase | Merge into existing rules |
| Vague "be careful about..." rules | Lack specificity, won't change LLM behavior | Convert to concrete NEVER/ALWAYS prohibitions/requirements |
| Placing project-specific rules in global rules/ | Unnecessary rules loaded in other projects | Put in project's CLAUDE.md |

## 6. External Case Study Reference

Details of external cases that informed design principles P1-P6.

### Reflexion (Shinn et al., 2023) → Principle P4

- **Paper**: arxiv 2303.11366
- **Mechanism**: 4-step loop: Actor → Evaluator → Self-Reflection → Memory. Accumulates "semantic gradients" as natural language in memory without weight updates
- **Result**: HumanEval pass@1 91%
- **Key insight**: Reflections managed via sliding window (max 1-3 entries). Memory bloat prevention is essential for quality maintenance

### SICA - Self-Improving Coding Agent (arxiv 2504.15228) → Principle P1

- **Mechanism**: Agent edits its own Python codebase (tools, prompts, workflows, helper functions) in a fully self-referential manner
- **Result**: SWE Bench 17% → 53%
- **Key insight**: Tooling improvements (file editing methods, code navigation, etc.) have greater impact than prompt improvements. Basis for prioritizing hooks/permissions in target selection

### claude-meta (aviadr1/claude-meta) → Principle P3

- **Mechanism**: Defines "meta-rules" (rules for writing rules) in CLAUDE.md
- **5 Principles**: (1) Start with NEVER/ALWAYS (2) Reason first (3) Include examples (4) One point per block (5) Prefer bullet points
- **Key insight**: Includes bloat prevention rules. Creates a cycle of compound quality improvement

### claude-reflect (BayramAnnakov/claude-reflect) → Principle P2

- **Mechanism**: 2-stage system. Stage 1 (auto): Hooks detect correction patterns in conversation and queue them. Stage 2 (manual): Human reviews and approves for sync
- **Key insight**: Human gatekeeping prevents quality degradation. Full automation carries error accumulation risk

### Godel Agent → Principle P2 (cautionary example)

- **Mechanism**: Recursively rewrites policies at runtime via Python monkey patching. MGSM 64.2% → 90.6%
- **Key insight**: Fully automatic recursive self-rewriting is unstable. Confirms the necessity of confirmation gates

### Anthropic Official Guidance → Principle P4

- **Mechanism**: Context engineering: "Minimal high-signal token set" as core principle. Compaction, subagent separation, just-in-time loading
- **Key insight**: Keep rules concise (1-2 sentences). Load references just-in-time

### Other Tool Comparison (Cursor/Windsurf/Copilot/Aider) → Principles P3, P5

- **Common**: All tools control behavior via Markdown-based rule files
- **Effective rule characteristics**: (1) Explicit prohibitions (2) Concrete code examples (3) Character limits enforce conciseness
- **Claude Code advantage**: Hooks system enables deterministic guardrails (block, modify, verify). Other tools are prompt-instruction only

### Post-Mortem Automation (Rootly AI, etc.) → Principle P6

- **Mechanism**: 5 Whys + systems thinking. Root causes are compound factors, not single points of failure
- **AI coding categories**: Context gap / Instruction ambiguity / Tool misuse / Guardrail gap
- **Key insight**: Phase 2's 5-perspective root cause analysis is an expansion of these 4 categories

---
name: analyze
description: |
  Support data-driven decision-making through interactive sparring.
  Use `/analyze start [topic]` to begin a new sparring session.
  Use `/analyze [question]` to continue (fresh subagent per rally with snapshot + recent context).
  Use `/analyze end` to end the session.
  Works with any material type — quantitative (KPIs, funnels, cohort data), qualitative (interviews, feedback), or mixed.
  Use when: making sense of data, organizing information for decision-making, deriving non-obvious implications, determining next actions from analysis.
  Do not use when: extracting JTBD from customer behavior (→ dex), designing research plans or interview guides (→ research).
user-invocable: true
args: "[args]"
---

# Analyze — Interactive Sparring Partner

An interactive sparring partner that supports the user's analytical thinking. The user is the analyst — this skill provides multi-perspective reactions to sharpen the user's own thinking.

## Architecture

- **Fresh subagent per rally**: Each `/analyze [question]` launches a new `general-purpose` subagent with a clean context. The sparring prompt dominates the SA's context, ensuring high instruction salience
- **Snapshot + recent rallies (sliding window)**: State is a point-in-time snapshot (compressed summary) plus the last 3 rally exchanges in full text. Size stays bounded regardless of total rally count
- **Context purity**: The SA's context contains only the sparring prompt, snapshot, recent rallies, and current question — no CLAUDE.md, no tool definitions, no unrelated conversation history
- **Rally SA (self-contained)**: The Continue workflow uses a single Rally SA that reads the session file, generates the sparring reaction, and updates the session file — all internally. The parent only passes `session_path` and `question`, and receives ONLY the reaction text. This keeps file I/O output and state extraction out of the parent context
- **Writer SA for lifecycle I/O**: Session file creation (Start) and conclusion (End) are delegated to a writer subagent

## Argument Routing

| Args                                                 | Action                                                   |
| ---------------------------------------------------- | -------------------------------------------------------- |
| `start [topic]`                                      | → **Start** workflow                                     |
| `end`                                                | → **End** workflow                                       |
| `[question]` (any text that is not `start` or `end`) | → **Continue** workflow (launch fresh SA)                |
| (none)                                               | If active session: show status. If not: show usage guide |

## Strict Rules

- User leads, SA reacts — the SA does not initiate questions or drive the conversation
- Concrete over abstract — every reaction must be grounded in specifics, not generalities
- Conflict is valuable — when perspectives disagree, present the disagreement rather than resolving it
- The critical perspective resists premature convergence — but never contradicts what a previous SA instance proposed. It evolves its critique to address new weaknesses, not re-litigate settled points

## Anti-patterns

- **Platitudes**: Restating what the user already knows in polished language. Citing well-known examples (e.g., "Shopify runs a monolith") or repeating established critiques is not valuable. The SA must dig into the user's hidden assumptions or reframe the question itself
- **Premature convergence**: The critical perspective stops pushing back and agrees
- **Self-contradiction across rallies**: The SA criticizes content that a previous SA instance itself proposed. Each rally has a fresh SA, but the snapshot + recent rallies show what was previously proposed — the SA must respect its own prior proposals as starting points, not targets
- **Over-generalization**: Producing reactions that could apply to any topic
- **Leading questions**: The SA asking questions to steer the analysis (it should only react)
- **Framework imposition**: Introducing MECE, SWOT, etc. unless explicitly requested

---

## No-args Behavior

1. Glob `~/.analyze/*.md`, Grep for `rally: ongoing`
2. If active sessions exist: display topic + date, show "Use `/analyze [question]` to continue"
3. If no active sessions: show the argument routing table

---

## Start Workflow: `/analyze start [topic]`

### 1. Guard

Generate slug from topic. Check if `~/.analyze/{today}_{slug}.md` exists with `rally: ongoing`. If so: "A session with the same name already exists. Use `/analyze [question]` to continue, or specify a different topic."

### 2. Receive materials and confirm topic

- Use `[topic]` argument as the starting point
- If materials are available (user mentions files, data, context), read them and summarize. Record their absolute file paths as `materials_path` for the session frontmatter
- Estimate materials token count (file size ÷ 3 for Japanese, ÷ 4 for English)
- If estimated tokens > 20K: AskUserQuestion — "Materials are large (estimated ~{N}K tokens). Choose: read originals each rally (higher cost) or generate a digest (lower cost, slightly less specificity)"
  - "Use as-is" → materials_mode: full
  - "Generate digest" → materials_mode: digest → proceed to Step 2.5
- If estimated tokens ≤ 20K: materials_mode: full (no confirmation needed)
- If no materials mentioned, proceed without — the user can provide context during the sparring dialogue
- Confirm: what does the user want to think through?

### 2.5. Generate materials digest (only when materials_mode is digest)

Launch a synchronous general-purpose subagent to generate the digest:

```
Agent(
  mode: "bypassPermissions",
  prompt: <Digest SA Prompt Template with {materials_path} filled in>
)
```

The SA reads the materials, generates a high-density digest, and returns it.
The returned digest is passed to the Writer SA in Step 3 as {materials_digest}.

### 3. Create session file

Run `mkdir -p ~/.analyze`, then delegate file creation to a **synchronous** writer SA:

```
Agent(
  mode: "bypassPermissions",
  prompt: <Writer SA Prompt Template with operation=create, path, topic, materials_summary filled in>
)
```

The writer SA creates `~/.analyze/{YYYY-MM-DD}_{slug}.md` with the initial session content. See **Writer SA Prompt Template** section for the full file format.

### 4. Confirm

Display: "Sparring session started. Use `/analyze [question]` to begin."

---

## Continue Workflow: `/analyze [question]`

### 1. Session resolution

1. Glob `~/.analyze/*.md`
2. Grep for `rally: ongoing`
3. 0 files → "No active session found. Run `/analyze start` first."
4. 1 file → auto-select (do NOT read the file — only extract the file path)
5. Multiple → display list, ask user to choose

### 2. Launch Rally SA

```
Agent(
  mode: "bypassPermissions",
  prompt: <Rally SA Prompt Template with {session_path}, {question}, {today} filled in>
)
```

The Rally SA reads the session file, generates the sparring reaction, and updates the file — all internally. It returns ONLY the sparring reaction.

### 3. Display

Show ONLY the Rally SA's response to the user. Do not add commentary or reformat.

---

## End Workflow: `/analyze end`

1. Session resolution (same as Continue workflow step 1)
2. Delegate file update to a **synchronous** writer SA:
   ```
   Agent(
     mode: "bypassPermissions",
     prompt: <Writer SA Prompt Template with operation=conclude, path filled in>
   )
   ```
3. Ask user: "Sparring session concluded. Would you like to save key findings to agent-memory?"

---

## Writer SA Prompt Template

Replace `{placeholders}` with actual values. Choose the operation block that matches the current workflow.

```
You are a file writer agent for the analyze skill. Perform ONLY the specified file operation. Do not output anything else.

## Operation: {create | conclude}

### create
Path: {~/.analyze/YYYY-MM-DD_slug.md}

Write this exact content:

---
type: analyze-session
rally: ongoing
topic: "{topic}"
created: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
materials_path:                    # optional, omit key entirely if no materials with file paths were provided
  - "{path}"
materials_mode: {full | digest}    # optional, omit if no materials. default: full
rally_count: 0
---

{## Materials Digest — include only when materials_mode is digest}
{materials_digest content}

## Snapshot
Theme: {topic}
{Materials summary: {materials_summary} — include only if materials were provided}
Current thinking: Session started. Awaiting first question.
Key turning points: (none)
Unresolved questions: (none)

## Recent Rallies
(none)

### conclude
Path: {session file path}

1. Read the current file
2. Change frontmatter: rally: ongoing → rally: concluded
```

---

## Digest SA Prompt Template

Used in Start workflow Step 2.5 to generate a materials digest. Replace `{placeholders}` with actual values.

```
You are a digest generator for the analyze skill. Read the materials and create a high-density digest.

## Materials
{List each path from materials_path as bullet points — Read each file}

## Digest Rules
- Target size: 5-10K tokens
- MUST preserve: concrete data points (numbers, ratios, percentages), specific quotes, structural framework, key findings, causal relationships and patterns
- MUST omit: verbose explanations, repeated context, raw appendix data, methodology descriptions
- Output the digest directly — no commentary, no metadata
```

---

## Rally SA Prompt Template

Replace `{session_path}`, `{question}`, `{today}` with actual values. The SA handles materials mode branching internally (no parent-side conditional construction needed). If snapshot indicates session start, the SA should treat it as the first rally.

```
You are the rally agent for a sparring session.
You read the session file, generate a sparring reaction, and update the file — all self-contained.

## Step 1: Read the session file

Use the Read tool to read the following file:
{session_path}

Extract the following from the file:
- `topic` from frontmatter
- `rally_count` from frontmatter
- `materials_path` from frontmatter (empty if key is absent)
- `materials_mode` from frontmatter (if key is absent: `full` when materials_path exists, otherwise empty)
- Contents of the `## Materials Digest` section (empty if absent)
- Contents of the `## Snapshot` section
- Contents of the `## Recent Rallies` section

## Step 2: Read materials (if applicable)

- If materials_mode is `full` and materials_path exists: Read each file using the Read tool
- If materials_mode is `digest`: Use the Materials Digest extracted in Step 1 as-is
- If no materials: Skip this step

## Step 3: Generate the sparring reaction

You are a sparring partner.
The user is the thinker — your role is to integrate and present reactions from multiple perspectives.
The user does the analysis. You react to the user's thinking and provide stimulus.

Use the theme, snapshot, and recent rallies extracted in Step 1 as context,
and reference the materials from Step 2 (if any) to react to the following user question.

### User's question
{question}

### Three perspectives

Internally consider from 3 distinct perspectives and return only the integrated result.
Do not output the raw reactions of the 3 perspectives. Return only the integrated "reaction."

#### Affirmer (lateral thinking orientation)
Draw out possibilities latent in the user's question or thinking and extend them in unexpected directions.
Apply at least one of the following techniques:
- **Reversal**: Flip the user's assumptions or causality ("X causes Y" → "What if Y came first and attracted X?")
- **Analogy transfer**: Import structurally similar patterns from a different field or context ("Isn't this the same structure as Y in the domain of X?")
- **Stakeholder shift**: View from a perspective the user has not considered ("What about from the perspective of churners, not beneficiaries?" "What if you see it as the designed, not the designer?")
- **Concept decomposition**: Break apart a concept the user treats as monolithic ("You say 'growth,' but quantitative expansion and qualitative deepening are different phenomena, aren't they?")
- **Time-axis shift**: View the present from a different point in time ("If this structure is still intact 3 years from now, what has changed?")

★ Judge by whether it shakes the frame of the user's thinking, not by logical validity.
  Prefer "rough but unexpected" over "correct but predictable."

#### Critic (logical thinking orientation)
Find and probe weaknesses in the user's question or thinking.
- "Does that assumption really hold?" "Here is a counterexample"
- "That data alone does not support that conclusion"
★ Cardinal rule: Do not converge easily. Maintain a critical eye at all times.
  However, there is discipline in "what to criticize":
  - If the user adopted content proposed/recommended in the previous rally's SA response,
    do not negate the adoption itself (that would be self-contradiction)
  - Instead, shift focus to "new weaknesses or blind spots that arise from having adopted it"
  - Criticism must be grounded in concrete counterexamples, data, or logical flaws

#### Neutral (systems thinking orientation)
Provide a bird's-eye reaction informed by both the affirmative and critical sides.
- "Looking at the overall structure..." "The impact of this decision on other elements..."
- "Viewed on a different time axis..."

### Output rules

1. Return only the integrated "reaction" (raw output of the 3 perspectives is internal processing only)
2. When perspectives conflict, present the conflict as-is rather than forcing resolution
3. Maintain specificity — react in ways specific to these materials and this situation
4. Do not ask questions unless the user asks first (stay in reaction mode)
5. Use WebSearch or other tools to supplement information before reacting if needed
6. Be concise. Return sharp reactions, not lengthy lectures
7. Phase recognition: Check "Current thinking" in the snapshot.
   If the user is in a convergence/finalization phase ("I want to produce an answer," "I want to summarize"),
   the Critic shifts role from "pointing out new weaknesses" to
   "proposing improvements to the precision, expression, and structure of the output"
8. Lateral protection: Always include at least one of the Affirmer's most surprising proposals in the integrated result.
   Even if the logical basis is weak, adopt it with a caveat like "rough, but..." when it serves as stimulus for thinking.
   However, this protection may be relaxed during the convergence phase (when refining the precision of a summary)

★ Do not restate things the user likely already knows.
  Listing famous examples ("Shopify runs a monolith") or repeating established critiques adds no value.
  Instead: surface implicit assumptions the user is unaware of, or reframe the question itself.
  A reaction that does not surprise the user is a failed reaction.

## Step 4: Generate the updated snapshot

After generating the sparring reaction, internally generate an updated snapshot in the following format (do not return to the user):

Theme: {current understanding of the theme}
Current thinking: {how far the thinking has progressed}
Key turning points: {list major insights or direction changes from the dialogue}
Unresolved questions: {list things still being explored}

## Step 5: Update the session file

Use the Edit tool to update the session file ({session_path}) directly.

Perform the following 4 edits in order:
1. Replace the contents of the `## Snapshot` section with the new snapshot from Step 4
2. Append a new rally to the end of the `## Recent Rallies` section:
   ### Rally {rally_count + 1}
   **Q**: {question}
   **A**: {reaction from Step 3}
3. If there are more than 3 rally entries, delete the oldest
4. Update `rally_count` in frontmatter to current value + 1, and `last_updated` to {today}

Proceed to Step 6 only after all edits are complete.

## Step 6: Return only the reaction

Return to the user ONLY the sparring reaction from Step 3.
Do NOT include any of the following:
- Snapshot
- File update reports or results
- Agent launch reports
- Procedure explanations
- Meta-commentary

Output only the sparring reaction.
```

---

## Session File Format

Path: `~/.analyze/{YYYY-MM-DD}_{slug}.md`

The session file holds the snapshot (compressed state) and recent rallies (detailed recent context). Together they provide the SA with full context on each invocation.

```markdown
---
type: analyze-session
rally: ongoing | concluded
topic: "{topic}"
created: { YYYY-MM-DD }
last_updated: { YYYY-MM-DD }
materials_path: # optional, omit if no materials provided
  - "{path}"
materials_mode: full | digest # optional, omit if no materials. full = SA reads original files each rally. digest = SA uses stored digest
rally_count: { integer }
---

## Materials Digest # only present when materials_mode is digest

[High-density digest of materials]

## Snapshot

Theme: ...
Current thinking: ...
Key turning points: ...
Unresolved questions: ...

## Recent Rallies

### Rally {n}

**Q**: {question}
**A**: {sparring reaction}
```

Recent Rallies keeps the last 3 entries. When a 4th is added, the oldest is removed. Key insights from removed rallies are preserved in the Snapshot.

**Separation of Rally SA and Materials Digest**: `## Materials Digest` is written once at Start time. Rally SA's Step 5 only replaces `## Snapshot` and appends to `## Recent Rallies`, so `## Materials Digest` is automatically protected as long as it precedes Snapshot.

**Backward compatibility**: Session files without the `materials_mode` key (from a previous kaizen) are treated as `full`. Older sessions without `materials_path` either operate as no-materials sessions as before.

---

## Completion

This skill is complete when:

- The user has sharpened their thinking through the sparring dialogue
- Or the user explicitly ends the session with `/analyze end`

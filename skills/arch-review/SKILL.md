---
name: arch-review
context: fork
description: |
  Evaluate design quality across 4 axes (cohesion / coupling / simplicity / testability).
  Analyzes the diff of the current branch or a PR using parallel subagents per axis, then consolidates results into a confidence-annotated report.
  Use when: performing a design review / architecture evaluation before a PR, or reviewing another engineer's PR for design quality.
  Do not use when: detecting bugs, security issues, or convention violations (-> /review, /ultrareview), or auditing existing code without a diff.
user-invocable: true
args: "[PR number | branch name]"
---

# arch-review — 4-Axis Design Quality Review

A portable skill that evaluates design across 4 axes. Focuses on **design health**, not bugs.

## 4 Axes

| Axis | Perspective |
| --- | --- |
| **Cohesion** | Co-location / SRP / physical expression of responsibility |
| **Coupling** | Dependency direction / co-location / circular deps / leaks |
| **Simplicity** | YAGNI / unused exports / over-abstraction / premature optimization |
| **Testability** | DI / side-effect isolation / test existence / pure functions vs. side-effect boundaries |

Readability is not a standalone axis — it is integrated into the summary comment as a consequence of the other axes.

## Workflow

### Step 1: Detect the base branch

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
```

If that fails, try `git rev-parse --verify origin/<name>` in order: `main` → `master` → `develop` → `trunk`. If none succeed, report "Cannot determine base branch. Set the remote HEAD or ensure a known trunk branch (main/master/develop/trunk) exists" and stop.

`<base>` hereafter refers to the detected branch (e.g., `origin/master`).

### Step 2: Determine the diff target

Parse the argument strictly:

- **No argument** → `git diff <base>...HEAD --name-status --diff-filter=ACMRT`
- **Argument matching `^[0-9]+$` (PR number)** → `gh pr diff <N> --name-only`. Fall back to `gh pr view <N> --json files -q '.files[].path'` for older gh versions that do not support `--name-only`
- **Anything else** → treat as a branch name. Use `git diff <base>...<arg> --name-status --diff-filter=ACMRT` if `git rev-parse --verify origin/<arg>` or `git rev-parse --verify <arg>` succeeds. If both fail, exit with "branch `<arg>` not found"
- If two or more arguments are given, use only the first

**Interpreting output (no-argument / branch-name route):**

- `M <path>` / `A <path>` / `C <path>` / `T <path>` → treat `<path>` as a changed file
- `R100 <old> <new>` (rename) → use **new path `<new>`** as the changed file; retain `<old>` for the `location` field in findings as `<old> → <new>`

For PR-number routes, `--name-only`-style output does not carry rename info, so rename annotation may be omitted.

### Step 3: Exit if diff is empty

If there are zero changed files, report "Diff is empty. Run this from a branch that has changes relative to `<base>`" and stop.

### Step 4: Guard against excessive file count

If more than **20 files** changed, declare "Detected as a cross-cutting change. Grouping by immediate parent directory for split evaluation."

Grouping rules:

- Group each changed file by its **1-level parent path**
- If there are **more than 5 groups**, re-group by the 2-level parent path (repeat until 5 or fewer groups)
- If re-grouping all the way to repo root still yields more than 5 groups, treat everything as **1 group** under `## Group: <repo root>` (split-evaluation mode is maintained; fast path is disabled)
- Only Steps 5 / 9 / 10 / 11 repeat per group; Step 6 (convention auto-read) and Step 7 (axes load) run **once** for the whole review; Step 8 (fast path) is **disabled in split-evaluation mode**
- Output the final report separated by `## Group: <path>`
- Reconcile cross-axis trade-offs within each group; leave cross-group contradictions as a top-level summary comment at the end of the report

### Step 5: Collect neighbor files

For each changed file (use only the **new path** for renames), list all files in its directory with `ls <dir>`. Retain only the path list — do not open the files (subagents open what they need).

Neighbor file usage rules:

- ✅ **Use as signal**: reference which types of files are co-located (variety, presence of corresponding tests, separately placed hooks, etc.) when evaluating cohesion and coupling
- ❌ **Do not include in findings**: never issue a finding against a neighbor file that is not in the changed-file list (e.g., "the neighboring `utilA.ts` has too many responsibilities" is invalid). Every finding's `location` must point to a changed file

### Step 6: Auto-read repository conventions

Read the following if they exist; skip otherwise. **Total limit for Step 6: 1 `CLAUDE.md` file + 3 files under `docs/` = at most 4 files, first 200 lines each:**

- First 200 lines of `CLAUDE.md` (counts as 1 file slot)
- Files under `docs/` whose name contains `architecture`, `coding-standard`, `design`, or `convention` (at most 3 files, first 200 lines each; ignore any beyond the limit)
- Do **not** follow `@`-imports or nested CLAUDE.md files (initial version)

Treat conventions as **reference context only** — axis judgments remain independent (do not let conventions override axis results).

### Step 7: Load `references/axes/*.md`

The parent Claude reads the following 4 files (under skill base directory `~/.claude/skills/arch-review/`):

- `references/axes/cohesion.md`
- `references/axes/coupling.md`
- `references/axes/simplicity.md`
- `references/axes/testability.md`

Hold each file's content as a string. Because subagents do not inherit skill files automatically, embed the content verbatim in each subagent prompt.

### Step 8: Fast-path check for small diffs

**Skip this step if split-evaluation mode (Step 4) was triggered — proceed to Step 9.**

LoC command depends on Step 2 routing:

- **No argument** → `git diff --shortstat <base>...HEAD`
- **PR number** → `gh pr diff <N> --stat | tail -1` (interpret the trailing `X insertions(+), Y deletions(-)`)
- **Branch name** → `git diff --shortstat <base>...<branch>`

If insertions + deletions ≤ 50 **and** changed files ≤ 2, use the fast path:

- Send all 4 axis definitions to a single `Explore` subagent for sequential evaluation
- Avoids the overhead of 4 parallel subagents
- **Output format is identical to Step 9's shared template**: return findings in 4 sections `## Cohesion`, `## Coupling`, `## Simplicity`, `## Testability` (evaluation is sequential internally, but output structure matches the parallel form)

Otherwise, proceed to Step 9.

### Step 9: Launch 4 axis subagents in parallel

Dispatch the following 4 `Explore` subagents **in a single message**:

| Subagent | Description | Prompt content |
| --- | --- | --- |
| Cohesion | "Cohesion analysis for arch-review" | `references/axes/cohesion.md` content + shared template (below) |
| Coupling | "Coupling analysis for arch-review" | `references/axes/coupling.md` content + shared template |
| Simplicity | "Simplicity analysis for arch-review" | `references/axes/simplicity.md` content + shared template |
| Testability | "Testability analysis for arch-review" | `references/axes/testability.md` content + shared template |

**Shared template (append to the end of each prompt):**

```
---

## Target

Changed files (issue findings against these):
<list of changed file paths>

Neighbor files (reference context — path list only; open them yourself if needed; do not issue findings against them):
<list of neighbor file paths>

## Repository conventions (reference only — axis judgments remain independent)

<content read in Step 6, if any>

## Output format

Output structured Markdown conforming to `references/templates/report.md`, listing all findings. Each finding must include:

- **Axis tag (perspective tag)**: choose from the standard set for this axis
  - Cohesion: `co-location` / `SRP` / `responsibility-expression` / `export-granularity` / `over-fragmentation`
  - Coupling: `dep-direction` / `circular-dep` / `over-re-export` / `cross-cutting-dep` / `import-overload` / `depth`
  - Simplicity: `YAGNI` / `unused-export` / `premature-abstraction` / `premature-generics` / `over-defensive` / `single-use-abstraction`
  - Testability: `test-absence` / `side-effect-isolation` / `DI` / `pure-fn-separation` / `over-DI`
  - **Do not create tags outside the standard set.** If no tag fits precisely, choose the closest one and clarify the specific concern in the finding body (to keep tag vocabulary stable)
- **confidence**: high / mid / low
- **direction**: add (requests separation/abstraction) / simplify (requests consolidation/deletion) / neutral (no direction)
- **location**: `<file:line>` or `<file>` (whole-file finding). For renames, use `<old-path> → <new-path>`
- Observation 1-3 lines + recommended action 1-2 lines (no code examples)

List items you cannot assert confidently as confidence: low with "judgment deferred (depends on author intent)".
Only mark something high if the code alone supports the assertion.
```

### Step 10: Handle subagent failures

If any axis subagent fails or times out, include `## <Axis>\n\nN/A (analysis failed: <reason>)` in that section. Complete the report for the remaining 3 axes — do not abort the whole skill.

### Step 11: Reconcile cross-axis trade-offs

The parent Claude merges the 4 axis Markdown results:

**Match key rules:**

- Extract only the `<file>` path from each finding's `location` (strip `:line` if present)
- For rename annotations `<old> → <new>`, use the **new path `<new>`** as the match key
- Among findings matched to the same file path:

1. Collect all findings and group them by axis section
2. Identify findings with confidence: high under the same file path
3. If any **`direction: add` and `direction: simplify` combination** exists for the same file, extract it into a "Cross-axis trade-offs" section (keep references to both original findings)
4. Leave neutral pairs and mid/low contradictions in their respective axis sections

### Step 12: Prioritize findings

Assign each finding a **P1-P4** priority label and list them in a "Priority improvements" section at the top of the report. **Do not add new metadata** — derive priority from existing combinations of confidence / direction / axis only.

**Ranking rules (evaluate in order; place in the first matching bucket):**

- **P1 (must fix)**: A confidence: high finding where **2 or more axes point to the same location**. Represents a fundamental design concern that should be addressed before other fixes
  - Use the same match key as Step 11 (`<file>` path only; rename → new path). However, if findings include **both `add` and `simplify` directions**, do not place in P1 — leave them in the "Cross-axis trade-offs" section (listing them as top priority would be misleading)
- **P2 (should fix)**: A confidence: high finding from a single axis. Demote to P3 if `direction: neutral` (naming/readability issues with limited design-health impact)
- **P3 (nice to have)**: All confidence: mid findings, plus neutral high findings demoted from P2
- **P4 (judgment deferred / check with author)**: All confidence: low findings (same content as the existing "Deferred" section, re-presented from a priority perspective)

**Sort order:**

- Descending: P1 → P2 → P3 → P4
- Within the same bucket: **file path alphabetically**; multiple findings in the same path: **axis name alphabetically** (cohesion → coupling → simplicity → testability)
- In P1, list each axis's finding on a **separate line** — do not merge them (to preserve each axis's rationale)

**Output rules:**

- Place the "Priority improvements" section **immediately below the opening summary** (see Step 13 template structure)
- Use the same 1-line prefix format as axis sections (`[axis][tag][confidence][direction] <location>`), prepending `[P1]`–`[P4]`
- Each finding's details (observation + recommended action) remain in their axis section; the priority section includes only a **1-line summary** (avoid duplication)
- Keep the "Cross-axis trade-offs" and "Deferred" sections as-is — the priority section is a "first-read index", not a replacement for axis detail

### Step 13: Output the report

Output the final report to the console following the structure in `references/templates/report.md`. Do not write to a file (initial version).

## Safety Guards Summary

- Empty diff → warn and stop
- File count > 20 → split evaluation by directory
- Subagent failure → mark that axis N/A, continue with remaining 3
- Neighbor files → reference only, never the subject of findings
- Rename/move (`--diff-filter=R`) → use new path for neighbor lookup; show `old → new` in findings
- Small diff → consolidate into 1 subagent instead of 4 parallel

## Key Principles

- **Assert only what the code proves.** Mark intent-dependent findings as confidence: low.
- **Conventions are context, not authority.** Do not let them override axis judgments.
- **No code examples in recommendations.** Keep recommended actions to 1-2 sentences.
- **No bug or type-error findings.** Those belong to other skills. Focus solely on design health.

---
name: research
description: |
  Support research design — building Research Questions (RQs), designing research plans, and creating interview guides.
  Built on the "Product Research Rules" 4-step framework, layered with FINER criteria, Known/Unknown matrix, and more.
  Use when: designing research (what to investigate and how)
  Do not use when: analyzing collected data (use insight-craft / dex), designing experiment hypotheses (use experiment-discipline)
  Subcommands:
    - (default): Subcommand guide
    - `rq`: Research Question construction sparring
    - `plan`: Research plan design
    - `interview`: Interview guide creation
user-invocable: true
---

# Research — Research Design Skill

A skill that supports the "design" phase of research through collaborative sparring. Self-contained, and can connect to downstream skills (insight-craft, dex, experiment-discipline).

## Common Principles

- **RQ ≠ Interview Question**: An RQ is "what you want to know"; an interview question is "how you ask it." Asking the RQ directly causes participants to guess the "expected answer"
- **Dialogue style**: Hybrid. Guide through dialogue while weaving in external research and domain knowledge
- **One question at a time**: Never ask multiple questions at once. Reduce cognitive load on the user
- **Weaving in research**: Present Claude's research not as "answers" but as material naturally woven into the sparring dialogue

## Subcommand Routing

| Argument    | Behavior                                                              |
| ----------- | --------------------------------------------------------------------- |
| (none)      | Show subcommand guide. Interview the user's situation and suggest one |
| `rq`        | → RQ construction workflow                                            |
| `plan`      | → Research plan workflow                                              |
| `interview` | → Interview guide workflow                                            |

**Default behavior (no argument)**:

> "Which stage of research can I help with?"
>
> - `rq` — Research Question construction
> - `plan` — Research plan design
> - `interview` — Interview guide creation

---

## `/research rq` — Research Question Construction

A layered, enhanced version of the "Product Research Rules" 4-step framework with quality gates at each step exit.

### Step 0: Pre-dialogue Preparation (Claude's side)

After the user shares their theme, Claude conducts research via WebSearch/WebFetch on the first turn:

- Basic domain structure (market, key players, trends)
- Existing research examples in similar areas
- Related academic findings and frameworks

Tell the user: "Let me do a bit of research on your theme before we start sparring." Weave research results naturally into the sparring from Step 1 onward. Do not present them all at once.

**Fallback**: If the theme is too vague to research, skip research and start directly from Step 1. Conduct research once the theme becomes more specific.

### Step 1: Capture Your Intuition

Verbalize the user's vague discomfort or interest.

- Ask: "What do you want to investigate?" "What kind of discomfort or unease do you feel?"
- Deepen the user's response by weaving in research results from Step 0
- Proceed one question at a time, continuing dialogue until the intuition is verbalized as 1-3 statements

**→ "Does this expression of your intuition feel right?"**

### Step 2: Decompose with 5W1H + Known/Unknown Matrix

Increase the resolution of the intuition and separate "what is known" from "what is unknown."

- For each intuition from Step 1, ask 5W1H questions one at a time (Who? What? Why? Where? When? How?)
- Sort each answer into "Known (fact)" and "Unknown (question)"

See [known-unknown-matrix.md](references/known-unknown-matrix.md) for details on the Known/Unknown matrix.

Output:

| 5W1H  | Known (facts) | Unknown (questions) |
| ----- | ------------- | ------------------- |
| Who   | ...           | ...                 |
| What  | ...           | ...                 |
| Why   | ...           | ...                 |
| Where | ...           | ...                 |
| When  | ...           | ...                 |
| How   | ...           | ...                 |

**→ "Does this breakdown look right? Which items in the Unknown column concern you most?"**

### Step 3: Evaluate & Filter with 3 Perspectives + FINER

From the "Unknown (questions)" identified in Step 2, filter down to questions worth investigating.

**Primary evaluation (3 perspectives)**:

1. **User perspective**: Is it important to the user?
2. **Business perspective**: Is it important to the business?
3. **Expert perspective**: Can it be answered with existing knowledge without research?

→ For the "Expert perspective," Claude conducts a web search. Questions already answered are excluded.

**Secondary evaluation (FINER criteria, applied to remaining questions)**:

- **F**easible: Can it be investigated with available resources?
- **I**nteresting: Will the team and stakeholders care?
- **N**ovel: Will it yield new insights?
- ※ Ethical / Relevant only when necessary

See [finer-criteria.md](references/finer-criteria.md) for details on FINER criteria.

Output: Prioritized question list

| Question | User | Business | Resolved by expert? | F   | I   | N   | Priority |
| -------- | ---- | -------- | ------------------- | --- | --- | --- | -------- |

**→ "Looking at these results, which questions would you like to turn into RQs?"**

### Step 4: RQ Formulation + Quality Check

Turn the selected questions into specific, researchable question statements.

- Ask the user to write an RQ first (rough is fine)
- Evaluate with [rq-quality-checklist.md](references/rq-quality-checklist.md) and provide feedback
- Iterate improvements through dialogue until the user is satisfied with the RQ

**→ On completion: "You can also design a plan with /research plan or create an interview guide with /research interview" (optional)**

---

## `/research plan` — Research Plan Design

### Entry Gate

"What do you want to clarify through this research?"

| User's state        | Response                                                  |
| ------------------- | --------------------------------------------------------- |
| Presents a clear RQ | Proceed directly → Step 1                                 |
| Vague explanation   | Confirm direction in 1-2 exchanges → Step 1               |
| "I don't know"      | Suggest `/research rq` and recommend building an RQ first |

**What this does NOT do**: Full RQ construction (4 steps). The entry gate only confirms "directional alignment."

### Step 1: RQ Nature Analysis

Determine the research direction based on the nature of the RQ:

- **Exploratory** (Why? How?) → Qualitative research recommended (interviews, behavioral observation)
- **Confirmatory** (Is X true? Which one?) → Quantitative research recommended (surveys, A/B testing)
- **Mixed** → Sequential design: qualitative to form hypotheses, then quantitative to validate

**→ Confirm the RQ nature and recommended direction with the user**

### Step 2: Research Method Selection

Based on the direction from Step 1, propose specific methods with pros/cons and fit analysis.

See [research-methods.md](references/research-methods.md) for method details.

Claude research: Conduct web research on best practices during method selection.

**→ User selects a method**

### Step 3: Participant Definition

- Screening criteria (age, occupation, behavioral characteristics, etc.)
- Recruitment criteria
- Sample size guidelines (qualitative: 5-8 participants, quantitative: statistically significant N)

**→ Confirm participant definition with the user**

### Step 4: Analysis Approach

- How to analyze collected data to answer the RQ
- Qualitative: thematic analysis, affinity diagramming, KJ method, etc.
- Quantitative: descriptive statistics, cross-tabulation, hypothesis testing, etc.
- Completion criteria for analysis (what constitutes having answered the RQ)

Output: Research plan document (a single document summarizing RQ, methods, participants, estimated schedule, and analysis approach)

**→ Confirm the entire research plan with the user. Iterate revisions as needed**

---

## `/research interview` — Interview Guide Creation

### Entry Gate

"What do you want to clarify through this interview? Who are the participants?"

| User's state      | Response                                                                      |
| ----------------- | ----------------------------------------------------------------------------- |
| Has RQ + plan     | Proceed directly → Step 1                                                     |
| Has RQ only       | Briefly confirm participants and time allocation → Step 1                     |
| Vague explanation | Confirm purpose and participants in 1-2 exchanges → Step 1                    |
| "I don't know"    | Suggest `/research rq` and recommend clarifying "what you want to know" first |

**What this does NOT do**: Research plan creation, full RQ construction.

### Step 1: Converting RQs to Interview Questions

Core principle: **RQ ≠ Interview Question**

For each RQ, design a set of questions that indirectly elicit answers.

See [interview-design.md](references/interview-design.md) for RQ → IQ conversion principles and examples.

Conversion checks:

- Is it non-leading?
- Is it open-ended? (doesn't end with Yes/No)
- Does it ask about specific experiences? ("the last time you..." rather than "usually...")

**→ Confirm conversion results with the user**

### Step 2: Interview Structure Design

4-part structure:

1. **Warm-up** (5-10 min): Build rapport. Questions related to the theme but easy to answer
2. **Core questions** (20-30 min): Question sets converted in Step 1. Elicit answers to the RQs
3. **Deep-dive questions**: Prepare follow-up patterns for each response ("Why is that?" "Can you be more specific?" "What else?")
4. **Closing** (5 min): Check for "anything else you wanted to share" or "anything we missed"

Output: Interview guide with explicit RQ mapping for each question

| #   | Section | Question | Mapped RQ | Intent        |
| --- | ------- | -------- | --------- | ------------- |
| 1   | Warm-up | ...      | -         | Build rapport |
| 2   | Core    | ...      | RQ1       | ...           |
| ... | ...     | ...      | ...       | ...           |

**→ Confirm the interview guide with the user. Iterate revisions as needed**

---

## Responsibility Boundaries

|                                  | rq  | plan | interview |
| -------------------------------- | --- | ---- | --------- |
| Full RQ construction (4 steps)   | Yes | No   | No        |
| Brief directional confirmation   | -   | Yes  | Yes       |
| Research method selection        | No  | Yes  | No        |
| Full participant definition      | No  | Yes  | No        |
| Brief participant confirmation   | No  | -    | Yes       |
| IQ design                        | No  | No   | Yes       |
| Redirect when context is lacking | -   | Yes  | Yes       |

## Downstream Skill Connections

- `/research rq` → Starting point for conducting interviews
- Interview logs → `/dex` (JTBD extraction) / `/insight-craft` (insight discovery)
- Insights / JTBD → `/experiment-discipline` (experiment design)

## Artifact Management

### SSOT Principle

The SSOT for artifacts is agent-memory. The plan file is a working document during the session, not the final version. Output to external files (e.g., ~/Downloads) is done only on user request, generated from agent-memory content. Do not maintain the same content in multiple locations.

### Constraint Management

Constraints discovered during dialogue (e.g., via criticize, such as "hypothetical questions are NG because they demand self-analysis") are saved as `constraints.md` in the relevant research directory in agent-memory. When updating artifacts, always re-read constraints.md and verify no constraints are violated.

### Consistency Check Gate

When an RQ is modified or before outputting an interview guide, run a consistency check by referring to [artifact-consistency-checklist.md](references/artifact-consistency-checklist.md).

## Strict Rules

1. Never skip checkpoints (→)
2. Always distinguish RQ ≠ Interview Question
3. Never present Claude's research as "answers" — weave them in as sparring material
4. Proceed one question at a time — never ask multiple questions at once
5. Do not force progress at the entry gate — if context is lacking, direct to the appropriate subcommand
6. Do not perform full RQ construction (4 steps) within `/research plan` or `/research interview`
7. When a quality check shows all items OK, identify the weakest item and explicitly state the rationale for marking it OK
8. Conduct external research only within a range that does not disrupt the dialogue flow
9. The SSOT for artifacts is agent-memory — the plan file is a working document during the session, not the final version
10. When an RQ, hypothesis, or guide is modified, run a consistency check based on [artifact-consistency-checklist.md](references/artifact-consistency-checklist.md)
11. Save constraints discovered during dialogue to constraints.md in agent-memory, and re-read them when updating artifacts
12. Do not rank exploratory RQs and hypothesis-driven RQs — propose the appropriate type based on the user's knowledge state

## Completion Criteria

### `/research rq`

- At least one RQ has passed the quality checklist
- The user is satisfied with the RQ

### `/research plan`

- A research plan document (RQ, methods, participants, analysis approach) is complete
- The user has agreed to the plan

### `/research interview`

- Interview questions are designed for all RQs
- A 4-part interview guide is complete
- The user has agreed to the guide

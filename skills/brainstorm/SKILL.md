---
name: brainstorm
description: |
  Collaborative design thinking before implementation. Explores intent, asks clarifying questions, proposes approaches, and presents design for approval.
  Use when: creating features, building components, adding functionality, modifying behavior, or any task that benefits from design-first thinking.
  Do not use when: the user explicitly requested superpowers workflow (e.g., "/superpowers:brainstorming"), simple bug fixes with obvious solutions, or purely investigative tasks.
user-invocable: true
args: "[topic]"
---

# Brainstorm — Collaborative Design Before Implementation

Turn ideas into fully formed designs through natural collaborative dialogue. Understand the project context, ask questions one at a time, then present a design for user approval.

This skill is a lightweight alternative to `superpowers:brainstorming`. It provides the same design-first thinking process without spec file generation — designs live in conversation and agent-memory only.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Prerequisites

- The user has an idea, task, or feature request that requires design decisions before implementation
- If the user's request is purely investigative (understanding code, searching for patterns), this skill does not apply

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Strict Rules

- This skill serves as a replacement for `superpowers:brainstorming`. Do NOT invoke `superpowers:brainstorming` unless the user explicitly requests it
- NEVER write spec files to `docs/superpowers/specs/` or any file system location — design lives in conversation and agent-memory only
- NEVER invoke `superpowers:writing-plans` — transition to Plan Mode via `EnterPlanMode` instead
- NEVER skip a checkpoint (→) without user confirmation
- NEVER ask multiple questions in a single message
- NEVER propose approaches without exploring the codebase first
- ALWAYS apply YAGNI — remove features the user did not ask for

## Workflow

### Step 1: Explore Project Context

Use Glob, Grep, Read, and `git log` to understand the current project state. If the user provided a `[topic]` argument, use it as the starting point.

- Check relevant source files, docs, and recent commits
- Identify existing patterns, conventions, and reusable components
- Scope this to design-level understanding only — gathering enough context to ask good questions and propose sound approaches. Detailed implementation-level exploration happens later in Plan Mode

### Step 2: Assess Scope

Before diving into detailed questions, evaluate the overall scope:

- If the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately
- Help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built?
- Then brainstorm the first sub-project through the normal design flow
- Each sub-project gets its own brainstorm → plan → implementation cycle

If the scope is already appropriate, move directly to Step 3.

### Step 3: Ask Clarifying Questions

Ask questions one at a time to refine the idea:

- Prefer multiple choice questions when possible (easier to answer than open-ended)
- Focus on understanding: purpose, constraints, success criteria
- Only one question per message — if a topic needs more exploration, break it into multiple questions

**→ Wait for user response before asking the next question.**

**Exit condition:** Move to Step 4 when the following are clear. If any item is missing, ask one targeted question to fill the gap before proceeding.

- **Purpose**: what problem this solves
- **Scope**: what is and isn't included
- **Key constraints**: technical, timeline, compatibility
- **Success criteria**: how to know it works
- **Alternatives**: at least 2 candidate approaches have surfaced
- **Information**: what's known vs unknown for the decision is acknowledged
- **Values**: what to optimize for is explicit (speed / reliability / extensibility / cost)

Underlying framework, 8 evaluation axes, and 16 failure patterns: `docs/design-decision-guide.md`

### Step 4: Propose 2-3 Approaches

Present approaches with trade-offs:

- Lead with your recommended option and explain why
- Include for each: architecture sketch, key components, data flow
- Be explicit about trade-offs (complexity, performance, maintainability)

**→ "Which approach would you like to go with? Or would you like to explore a different direction?"**

### Step 5: Present Design in Sections

Once the approach is selected, present the design section by section:

- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Cover as relevant: architecture, components, data flow, error handling, testing approach

**→ After each section: "This section covers [topic]. Does this look right?"**

Design principles to follow:
- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit: what does it do, how do you use it, what does it depend on?
- Smaller, well-bounded units are easier to implement reliably

Working in existing codebases:
- Explore the current structure before proposing changes. Follow existing patterns
- Where existing code has problems that affect the work, include targeted improvements as part of the design
- Don't propose unrelated refactoring. Stay focused on what serves the current goal

**→ After all sections are approved: "The design is complete. Shall I save this to memory and move on to implementation planning?"**

### Step 6: Transition

Execute the following in order:

**a. Save design to agent-memory**

Save the approved design to agent-memory with the following content:
- Context: what problem this solves, what prompted it
- Selected approach and rationale (why this over alternatives)
- Each approved design section
- Key decisions made during the dialogue

Use scope = current repository name, directory = `<YYYY-MM-DD>_<topic>-design`, file = `design.md`.

**b. Enter Plan Mode**

Invoke `EnterPlanMode` to transition to implementation planning. When entering Plan Mode:
- Include a summary of the approved design at the start of the plan context
- Reference the agent-memory path for full design details
- Plan Mode will apply `plan-template.md` and `plan-review.md` as usual

## Key Principles

- **One question at a time** — Don't overwhelm with multiple questions
- **Multiple choice preferred** — Easier to answer than open-ended when possible
- **YAGNI ruthlessly** — Remove unnecessary features from all designs
- **Explore alternatives** — Always propose 2-3 approaches before settling
- **Incremental validation** — Present design, get approval before moving on
- **Be flexible** — Go back and clarify when something doesn't make sense

## Skill Connections

- **Downstream**: This skill transitions to Plan Mode (`EnterPlanMode`), which produces an implementation plan following `plan-template.md`

## Completion

This skill is complete when:
- Design has been presented section by section and approved by the user
- Design decisions have been saved to agent-memory
- Plan Mode has been entered via `EnterPlanMode`

# Artifact Consistency Checklist

Run this checklist when an RQ is modified, before outputting an interview guide, or before outputting a survey question set.

## 1. RQ Text and Hypothesis Chain Alignment

- [ ] Are all elements (variables, relationships) that the RQ asks about included in the hypothesis chain?
- [ ] Are there any elements in the hypothesis chain that are not reflected in the RQ?
- [ ] Are sub-questions not duplicating the main RQ? (If a sub-question is already contained in the main RQ, there is no reason to break it out separately)

## 2. Participant-Perspective Terminology Check

- [ ] Are analyst-centric terms ("month-over-month retention," "cohort," "churn," etc.) absent from RQs and guides?
- [ ] Is the terminology grounded in participants' actions and experiences? (e.g., "month-over-month retention" → "using the service again the following month")
- [ ] Can the interviewer share these expressions with participants without additional explanation?

## 3. Guide Internal Consistency

- [ ] Does the sum of the time allocation table match the estimated time in section headings?
- [ ] Do time checkpoint cumulative times match the table?
- [ ] Is the buffer time calculation correct? (total duration - main sections - closing = buffer)
- [ ] Is the number of MUST questions realistic within the estimated time for each section?

## 4. Cross-File Synchronization Check

- [ ] Is the RQ text identical across all files (plan file, guide, agent-memory)?
- [ ] Is the hypothesis chain diagram identical across all files?
- [ ] Do the focus area names, counts, and contents match across all files?
- [ ] Is the scope description consistent across all files?

## 5. Constraint Compliance

- [ ] Does the content comply with constraints listed in `constraints.md` in agent-memory (if it exists)?
- [ ] Are problem patterns identified in previous criticize sessions not reintroduced?

## 6. RQ ↔ SQ Alignment (for survey artifacts)

Run this section when checking a survey question (SQ) set against its parent RQs.

- [ ] Is every Construct from the RQ's operationalization covered by at least one SQ Indicator?
- [ ] Is every SQ traceable back to a named Construct (no orphan SQs)?
- [ ] If validated scales (NPS, SUS, SERVQUAL, ACSI, CSAT, etc.) are adopted, is the original wording preserved verbatim?
- [ ] If any adaptation was applied to a validated scale, is the change and its rationale documented in `constraints.md`?
- [ ] After an RQ revision, has the affected SQ wording, scale design, and order been re-checked?

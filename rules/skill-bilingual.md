# Bilingual Document Management

## When

Apply when creating or editing any of the following files in this repository:
- `skills/*/SKILL.md`
- `CLAUDE.md`
- `rules/*.md`
- Subfiles under `skills/*/` (references, axes, templates, etc.)

## Naming Convention

Every Claude-read document has an English primary file. A Japanese mirror (`-ja.md`) may accompany it in the same directory for human reference only — Claude does not read it.

| Kind | Claude reads (English, primary) | Human reads (Japanese, mirror) |
|---|---|---|
| Skill | `skills/<name>/SKILL.md` | `skills/<name>/SKILL-ja.md` |
| Global instructions | `CLAUDE.md` | `CLAUDE-ja.md` |
| Rules | `rules/<topic>.md` | `rules/<topic>-ja.md` |
| Subfiles | `references/foo.md` | `references/foo-ja.md` (when needed) |

## Subfile Selection

Answer this question to decide:

**"Can I improve or modify this skill's design without reading this file?"**

- **No → Create a Japanese mirror**: files containing design intent, trade-offs, or evaluation criteria (e.g. `arch-review/axes/`)
- **Yes → Skip**: files containing Claude-only templates, procedural data, or output formats (e.g. `arch-review/templates/`)

When in doubt, skip (YAGNI).

## Drift Management

When editing an English primary file, update the corresponding `-ja.md` in the same session. The drift-detection hook (`hooks/check-bilingual-sync.sh`) warns if the primary is modified but the mirror is not.

## Exceptions

Skip updating the mirror when the change is:
- Typo or whitespace fix only
- Formatting change with no semantic difference
- The mirror does not yet exist (create it when meaning changes substantially)

## Language Quality

English primary files must be written in clear, imperative prose — the same register as CLAUDE.md rules. Avoid machine-translation tone. Japanese mirrors may include rationale and background that the English version omits.

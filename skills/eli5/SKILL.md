---
name: eli5
description: |
  Explain a topic like I'm 5 — dead-simple explanations for someone who knows nothing about the topic.
  Use when: the user types `/eli5 [topic]` (no topic = the preceding conversation's topic) or asks for a dead-simple explanation of how something works.
  Do not use when: the user wants a detailed or technical deep-dive on the topic.
user-invocable: true
args: "[topic]"
---

# ELI5 — Explain Like I'm 5

Explain the topic to someone who knows nothing about it. Use few words, everyday analogies, and no jargon.

Topic: $ARGUMENTS

If no topic is provided, explain the topic of the immediately preceding conversation. If there is no preceding conversation, ask what to explain.

## Output Format

Default to a text explanation in chat. ASCII diagrams are allowed.

Switch to visual output only when either of these holds:

- The user explicitly asks for a diagram or picture
- Understanding hinges on structure that ASCII cannot convey — spatial layout, multi-stage flows, or interactions among many elements

For visual output, use big pictures and few words:

1. If an Artifact tool is available, use it
2. Otherwise, write a self-contained HTML file to `/tmp/eli5-<topic-slug>.html` and open it with `open`

## Attribution

Based on [eli5](https://github.com/anthropics/claude-plugins-community/tree/main/eli5) by Thariq Shihipar.
MIT License.

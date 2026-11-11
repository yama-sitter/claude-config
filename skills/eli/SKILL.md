---
name: eli
description: |
  Explain a topic at a chosen age level — for someone who knows nothing about the topic. Age sets the depth of explanation, not the tone. Default age is 5 (dead-simple).
  Use when: the user types `/eli [age] [topic]` (no age = 5; no topic = the preceding conversation's topic) or asks for a dead-simple or beginner-level explanation of how something works.
  Do not use when: the user wants a detailed or technical deep-dive on the topic.
user-invocable: true
args: "[age] [topic]"
---

# ELI — Explain Like I'm N

Explain the topic to someone of the given age who knows nothing about it. The age is a knowledge level: how much the listener can follow without prior knowledge. Do not make the tone childish.

Arguments: $ARGUMENTS

## Parsing Arguments

- If the first token is an integer, it is the age; everything after it is the topic.
- Otherwise the age is 5 and the whole argument is the topic. Example: `/eli 3D printing` → age 5, topic "3D printing".
- If no topic is provided, explain the topic of the immediately preceding conversation. If there is no preceding conversation, ask what to explain.

## Age Levels

Anchors are 5, 10, and 15. Interpolate between them. Clamp outside the range: age 4 or below is treated as 5, age 16 or above as 15.

| Age | Terms | Analogies | Depth |
|---|---|---|---|
| 5 | No jargon. Short, everyday words only | Replace everything with familiar objects | What it does |
| 10 | Use a term only when you rephrase it right away | Use analogies, and also show the skeleton of how it works | How it works |
| 15 | Use correct terms, as few as possible | Analogies only support understanding | Why it works that way |

## Output Format

Default to a text explanation in chat. ASCII diagrams are allowed.

Switch to visual output only when either of these holds:

- The user explicitly asks for a diagram or picture
- Understanding hinges on structure that ASCII cannot convey — spatial layout, multi-stage flows, or interactions among many elements

For visual output, use big pictures and few words:

1. If an Artifact tool is available, use it
2. Otherwise, write a self-contained HTML file to `/tmp/eli-<topic-slug>.html` and open it with `open`

## Attribution

Based on [eli5](https://github.com/anthropics/claude-plugins-community/tree/main/eli5) by Thariq Shihipar.
MIT License. Modified to take an age argument.

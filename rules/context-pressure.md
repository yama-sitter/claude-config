# Context Pressure Guidelines

## When

Apply these rules continuously as a self-check during long conversations or complex tasks.

## Self-Diagnosis Checklist

Stop and check whether you are doing any of the following:

- Writing code without having read the relevant source files in this conversation
- Filling in file contents from memory instead of re-reading them
- Giving vague or generic responses where specifics are needed
- Losing track of decisions made earlier in the conversation
- Repeating work that was already completed

If any of these apply, you are under context pressure.

## Required Behavior Under Context Pressure

- Declare context pressure explicitly to the user before continuing
- Do not write code without reading the relevant source files first
- Do not skip Plan Mode when the task warrants it
- Use subagents to offload work and conserve context
- If the task cannot be completed properly, stop rather than producing low-quality output

## Preferred Mitigations

### Subagent Delegation

Subagents do not consume the parent's context — investigation details stay within the subagent; only the summary returns. Delegate when the work is genuinely large or independent:

- Exploratory investigation across 3+ files → Explore subagent (not for reading a few known files)
- Large log or test output analysis → subagent processes and returns summary
- Parallel work across independent, sizeable tracks

Do not delegate:

- Work you can finish yourself in a handful of tool calls
- Review, verification, or double-checking your own work — this belongs in the main agent loop, not a subagent
- A single small task split across multiple subagents

Cap parallel subagents at a small number (roughly 5-8) unless the user explicitly asks for more. Recent Opus-tier models tend to over-delegate — brief each subagent precisely once and do not re-derive its findings after it reports back.

### Context Recovery

- Summarize completed work before moving to the next phase
- Re-read critical files rather than relying on earlier context
- Suggest splitting remaining work into a new conversation if needed

## Output Control (Context Conservation)

- Do not repeat file contents back into the conversation
- Read only the needed range of a file (use offset/limit parameters), not the entire file
- For broad exploration, use an Explore subagent instead of running Glob/Grep repeatedly

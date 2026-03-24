# Context Pressure Guidelines

## When

Apply these rules continuously as a self-check during long conversations or complex tasks.

## Self-Diagnosis Checklist

Stop and check whether you are doing any of the following:

- Writing code without having read the relevant source files in this conversation
- Filling in file contents from memory instead of re-reading them
- Skipping verification or testing steps to move faster
- Giving vague or generic responses where specifics are needed
- Losing track of decisions made earlier in the conversation
- Repeating work that was already completed

If any of these apply, you are under context pressure.

## Required Behavior Under Context Pressure

- Declare context pressure explicitly to the user before continuing
- Do not write code without reading the relevant source files first
- Do not skip verification or testing steps
- Do not skip Plan Mode when the task warrants it
- Use subagents to offload work and conserve context
- If the task cannot be completed properly, stop rather than producing low-quality output

## Preferred Mitigations

1. Delegate mechanical subtasks to subagents
2. Summarize completed work before moving to the next phase
3. Re-read critical files rather than relying on earlier context
4. Suggest splitting remaining work into a new conversation if needed

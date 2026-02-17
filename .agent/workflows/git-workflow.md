---
description: workflow rules for making changes and pushing to github
---

# Git Workflow Rules

Before making any changes in this workspace, follow these rules:

## Rules

1. **Always confirm commit message with user before pushing to GitHub**
   - Before running `git commit` and `git push`, ask the user what commit message they want
   - Do NOT assume or auto-generate commit messages
   - Wait for user approval before pushing

2. **Commit messages must sound natural and student-written**
   - Never use language that implies AI assistance or external instructions (e.g., "implemented as requested", "added per instructions", "as discussed")
   - Write simple, straightforward developer-style messages (e.g., "added counter app with slider and history", "fixed lint warnings")
   - Messages should read like a student documenting their own work

## Example

When pushing changes:
1. Make the code changes
2. Ask: "What commit message would you like for this change?"
3. Wait for user response
4. Only then commit and push with the confirmed message

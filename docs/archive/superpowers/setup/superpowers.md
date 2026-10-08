# Superpowers for Cursor

<EXTREMELY_IMPORTANT>
You have superpowers. Superpowers are specialized skills that teach you workflows and capabilities for software development.

## Available Superpowers Skills

All superpowers skills are located in `~/.cursor/skills-cursor/superpowers/` and are automatically accessible through Cursor's skill system.

### Core Skills (Use these first!)

- **superpowers/using-superpowers** - MANDATORY: Use when starting ANY conversation. Establishes how to find and use skills.
- **superpowers/brainstorming** - MANDATORY before ANY creative work: creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.
- **superpowers/systematic-debugging** - MANDATORY when encountering any bug, test failure, or unexpected behavior, before proposing fixes.
- **superpowers/test-driven-development** - MANDATORY when implementing any feature or bugfix, before writing implementation code.

### Planning & Execution Skills

- **superpowers/writing-plans** - Use when you have a spec or requirements for a multi-step task, before touching code.
- **superpowers/executing-plans** - Use when you have a written implementation plan to execute in a separate session with review checkpoints.
- **superpowers/subagent-driven-development** - Use when executing implementation plans with independent tasks in the current session.
- **superpowers/dispatching-parallel-agents** - Use when facing 2+ independent tasks that can be worked on without shared state.

### Code Review & Completion Skills

- **superpowers/requesting-code-review** - Use when completing tasks, implementing major features, or before merging.
- **superpowers/receiving-code-review** - Use when receiving code review feedback, before implementing suggestions.
- **superpowers/verification-before-completion** - MANDATORY when about to claim work is complete, fixed, or passing.
- **superpowers/finishing-a-development-branch** - Use when implementation is complete and you need to decide how to integrate the work.

### Development Tools

- **superpowers/using-git-worktrees** - Use when starting feature work that needs isolation from current workspace.
- **superpowers/writing-skills** - Use when creating new skills, editing existing skills, or verifying skills work.

## Critical Rules for Using Superpowers

1. **Check for relevant skills BEFORE any response or action**
   - Even if there's only a 1% chance a skill might apply, you MUST read it
   - Skills must be checked BEFORE clarifying questions
   - Skills must be checked BEFORE exploring the codebase
   - Skills must be checked BEFORE gathering information

2. **When a skill applies, you MUST use it**
   - This is not negotiable or optional
   - You cannot rationalize your way out of using a skill
   - Follow rigid skills (TDD, debugging) exactly
   - Adapt flexible skills to context while maintaining discipline

3. **Announce skill usage**
   - When using a skill, announce: "I've read the [Skill Name] skill and I'm using it to [purpose]"
   - If a skill has a checklist, create TodoWrite todos for each item

4. **Skill Priority Order**
   - Process skills FIRST (brainstorming, debugging) - these determine HOW to approach
   - Implementation skills SECOND - these guide execution

## Red Flags (Stop and Check Skills!)

If you're thinking any of these, STOP and check for skills:
- "This is just a simple question"
- "I need more context first"
- "Let me explore the codebase first"
- "Let me gather information first"
- "This doesn't need a formal skill"
- "I remember this skill"
- "The skill is overkill"
- "I'll just do this one thing first"

## How to Access Skills in Cursor

Use Cursor's built-in skill system. Skills are automatically available from `~/.cursor/skills-cursor/superpowers/`.

To read a skill, simply reference it by path (e.g., `superpowers/brainstorming/SKILL.md`) and Cursor will load it.

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</EXTREMELY_IMPORTANT>

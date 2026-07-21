## Get the script :

```bash
curl -s -o .agents/rules-cli.sh https://raw.githubusercontent.com/Qua-9-9-1/AI-rules-getter/main/rules-cli.sh && chmod +x .agents/rules-cli.sh
curl -s -o .agents/prompt.md https://raw.githubusercontent.com/Qua-9-9-1/AI-rules-getter/main/README.md
```

## Prompt to agent :

```
Role: You act as a Software Architect and Context Manager for this project. Your goal is to analyze the codebase, standardize architecture documentation within the `.agents/` folder, and continuously keep this context strictly up-to-date as the project evolves.

Strict Global Directives:
- Continuous Context: Automatically update `.agents/context/` files whenever you detect structural, business, or tech stack changes.
- NO compatibility layers, no fallbacks, no stubs, no placeholders. All generated code, logic, and documentation must be complete, definitive, and production-ready.
- Anti-Hallucination: Never invent business logic. If project-specific context is missing to write a complete file, prompt the user for clarification rather than writing a placeholder.

Execution Instructions Step-by-Step:

Step 1: Current State Analysis
Scan the entire project to identify the exact technology stack (languages, frameworks, tools) and the macro-architecture. Identify if this is a fresh initialization or an ongoing project.

Step 2: Binary Information Separation (Context vs. Registry)
Apply this strict sorting rule:
- Project-specific information (business logic, repository goals, local architecture) = Destination: `.agents/context/`
- Reusable technology rules (language, framework, or architectural patterns) = Destination: `.agents/registry/`

Step 3: Local Context Structuring
Evaluate the current state of `.agents/AGENTS.md`.
- If it contains raw context: Empty its textual content and move the project-specific information into thematic sub-files in `.agents/context/` (e.g., `business-context.md`, `tech-stack.md`).
- If it is empty or missing: Initialize the `.agents/context/` sub-files based on your Step 1 analysis.

Step 4: Global Registry Retrieval & Update
For each technology identified in Step 1, populate the `.agents/registry/` subfolders (core/, languages/, frameworks/, infrastructure/, etc.) following this exact resolution order:

Condition A (File exists locally): Do not modify it under any circumstances.
Condition B (File missing locally): Execute `bash ./.agents/rules-cli.sh <technology_name>`.
- Success: The rule is now local. Do not modify it.
- Script Error / Missing Script: You must act as the fallback. Write the industrial coding best practices specific to this technology yourself. Save it strictly in the correct logical category. (Apply the "No stubs" rule: generate a comprehensive, expert-level guide).

Step 5: Entry Point Transformation (AGENTS.md)
Write or overwrite `.agents/AGENTS.md` to act exclusively as the main router/index for the project. 
List all files generated, downloaded, or identified strictly using relative Markdown links (e.g., `[Business Context](./context/business-context.md)`). Do not add explanations or summaries in this file, just the index.
```

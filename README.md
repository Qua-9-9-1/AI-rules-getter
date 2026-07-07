## Get the script :

```bash
curl -s -o .agents/rules-cli.sh https://raw.githubusercontent.com/Qua-9-9-1/AI-rules-getter/main/rules-cli.sh && chmod +x .agents/rules-cli.sh
curl -s -o .agents/prompt.md https://raw.githubusercontent.com/Qua-9-9-1/AI-rules-getter/main/README.md
```

## Prompt to agent :

```
Role: You act as a Software Architect and Context Manager for this project. Your goal is to analyze the current codebase and standardize the architecture documentation within the .agents/ folder.

Execution Instructions Step-by-Step:

Step 1: Current State Analysis
Scan the entire project to identify the exact technology stack (languages, frameworks, infrastructure tools) as well as the macro-architecture used.

Step 2: Binary Information Separation (Context vs. Registry)
Apply this strict sorting rule to generate your files:

Information strictly specific to this project (business logic, repository goals, local architecture) = Destination: .agents/context/

Information regarding a reusable technology (rules for a language, framework, or architectural pattern) = Destination: .agents/registry/

Step 3: Local Context Structuring
The .agents/AGENTS.md file currently contains raw context.

Empty its textual content.

Move the project-specific information by creating thematic sub-files in .agents/context/ (e.g., business-context.md, tech-stack.md, objectives.md).

Step 4: Global Registry Retrieval & Update
For each technology identified in Step 1, follow this exact resolution order to populate the .agents/registry/ subfolders (core/, languages/, frameworks/, infrastructure/, architectures/, libraries/, tooling/, formats/, api/):

Condition A (File exists locally): If the file is already present in .agents/registry/, do not modify it under any circumstances.

Condition B (File missing locally):

Execute the CLI tool to fetch the rule from the global registry by running: ./.agents/rules-cli.sh <technology_name> (e.g., ./.agents/rules-cli.sh react or ./.agents/rules-cli.sh rust).

If the script succeeds (file downloaded): The rule is now local. Do not modify the downloaded file.

If the script returns an error (file not found on remote registry): You must act as the fallback. Create this file yourself. Write the industrial coding best practices (cleanliness, readability, maintainability) specific to this technology, and save it strictly in the subfolder corresponding to its correct logical category.

Step 5: Entry Point Transformation (AGENTS.md)
Write the new content for .agents/AGENTS.md to make it the main router for the project. It must act exclusively as an index.
List all files generated, downloaded, or identified in the previous steps strictly using relative Markdown links (e.g., [Business Context](./context/business-context.md) or [React Rules](./registry/frameworks/react.md)).
```

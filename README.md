## Get the script :

```bash
curl -s -o .agents/rules-cli.sh https://raw.githubusercontent.com/Qua-9-9-1/AI-rules-getter/main/rules-cli.sh && chmod +x .agents/rules-cli.sh
curl -s -o .agents/prompt.md https://raw.githubusercontent.com/Qua-9-9-1/AI-rules-getter/main/README.md
```

## Prompt to agent :

```
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

Step 4: Global Registry Update (Reusable Rules)
For each technology identified in Step 1, check if a corresponding Markdown file already exists in the .agents/registry/ subfolders (core/, languages/, frameworks/, infrastructure/, architectures/).

If the file already exists: Do not modify it under any circumstances.

If the file does not exist: Create this file. Write the industrial coding best practices (cleanliness, readability, maintainability) specific to this technology, and save it in the subfolder corresponding to its category.

Step 5: Entry Point Transformation (AGENTS.md)
Write the new content for .agents/AGENTS.md to make it the main router for the project. It must act exclusively as an index.
List all files generated or identified in the previous steps strictly using relative Markdown links (e.g., [Business Context](./context/business-context.md) or [React Rules](./registry/frameworks/react.md)).
```

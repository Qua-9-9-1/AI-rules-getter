#!/bin/bash

# Repository Configuration
REPO_USER="Qua-9-9-1"
REPO_NAME="My-AI-rules"
BRANCH="main"

BASE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH/registry"

AI_DIR=".agents"
TARGET_FILE="$AI_DIR/rules.md"
AGENTS_FILE="$AI_DIR/agents.md"
CONTEXT_DIR="$AI_DIR/context"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CMD=$1
PARAM=$2

case $CMD in
    "init")
        mkdir -p "$CONTEXT_DIR"
        > "$TARGET_FILE"
        touch "$AGENTS_FILE"
        
        CORE_FILES=("architecture" "git-workflow" "tests" "docs" "security")
        
        for FILE in "${CORE_FILES[@]}"; do
            URL="$BASE_URL/core/$FILE.md"
            # Le flag -f permet à curl d'échouer silencieusement si le fichier n'existe pas (erreur 404)
            if curl -s -f "$URL" >> "$TARGET_FILE"; then
                printf "\n\n" >> "$TARGET_FILE"
            fi
        done
        
        if [ -f ".gitignore" ]; then
            grep -q ".ai/" ".gitignore" || printf "\n.ai/\n" >> .gitignore
        else
            printf ".ai/\n" > .gitignore
        fi
        
        echo -e "${GREEN}Environment initialized successfully.${NC}"
        ;;
        
    "add")
        if [ -z "$PARAM" ]; then
            echo -e "${RED}Error: Missing rule name.${NC}"
            exit 1
        fi
        
        CATEGORIES=("languages" "frameworks" "architectures" "infrastructure")
        FOUND=false
        
        for CAT in "${CATEGORIES[@]}"; do
            URL="$BASE_URL/$CAT/$PARAM.md"
            TEMP_FILE=$(mktemp)
            
            if curl -s -f "$URL" > "$TEMP_FILE"; then
                cat "$TEMP_FILE" >> "$TARGET_FILE"
                printf "\n\n" >> "$TARGET_FILE"
                echo -e "${GREEN}Rule '${PARAM}' added from ${CAT}.${NC}"
                FOUND=true
                rm -f "$TEMP_FILE"
                break
            fi
            rm -f "$TEMP_FILE"
        done
        
        if [ "$FOUND" = false ]; then
            echo -e "${RED}Error: Rule '${PARAM}' not found in remote registry.${NC}"
        fi
        ;;
        
    "list")
        API_URL="https://api.github.com/repos/$REPO_USER/$REPO_NAME/git/trees/$BRANCH?recursive=1"
        echo -e "${BLUE}Available remote rules:${NC}"
        curl -s "$API_URL" | grep -o '"path": "[^"]*\.md"' | awk -F'"' '{print $4}' | grep '^registry/' | sed 's/registry\///' | sort
        ;;
        
    *)
        echo "Commands:"
        echo "  rule init"
        echo "  rule add <rule_name>"
        echo "  rule list"
        ;;
esac
#!/bin/bash

REPO_USER="Qua-9-9-1"
REPO_NAME="My-AI-rules"
BRANCH="main"
BASE_RAW_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH"
API_URL="https://api.github.com/repos/$REPO_USER/$REPO_NAME/git/trees/$BRANCH?recursive=1"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

RAW_INPUT="$1"
TARGET=$(echo "$RAW_INPUT" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-')
SUBCMD=$(echo "$2" | tr '[:upper:]' '[:lower:]' | tr '_ ' '-')

if [ -z "$TARGET" ]; then
    echo -e "${RED}Error: Specify 'init', 'list [category]', or a technology name.${NC}"
    exit 1
fi

if [ "$TARGET" = "init" ]; then
    echo -e "${GREEN}Initializing AI environment...${NC}"

    mkdir -p context
    
    if [ ! -f "AGENTS.md" ]; then
        touch AGENTS.md
    fi

    mkdir -p registry/core
    CORE_FILES=("architecture" "git-workflow" "tests" "docs" "security")
    
    for FILE in "${CORE_FILES[@]}"; do
        URL="$BASE_RAW_URL/registry/core/$FILE.md"
        curl -s -f "$URL" -o "registry/core/$FILE.md"
    done

    # if [ -f ".gitignore" ]; then
    #     grep -q "^context/$" .gitignore || echo "context/" >> .gitignore
    #     grep -q "^AGENTS.md$" .gitignore || echo "AGENTS.md" >> .gitignore
    # else
    #     echo -e "context/\nAGENTS.md" > .gitignore
    # fi
    
    echo -e "${GREEN}Done.${NC}"

elif [ "$TARGET" = "list" ]; then
    TREE_DATA=$(curl -s "$API_URL" | grep -o '"path": "[^"]*\.md"' | awk -F'"' '{print $4}' | grep '^registry/')
    
    if [ -z "$SUBCMD" ]; then
        echo -e "${BLUE}Available technologies on the repo:${NC}"
        echo "$TREE_DATA" | grep -v '^registry/core/' | awk -F'/' '{
            file=$NF; 
            gsub(/\.md$/, "", file);
            path=$0;
            gsub(/^registry\/|\/[^\/]+$/, "", path);
            printf "  %-25s [%s]\n", file, path
        }' | sort
    else
        echo -e "${BLUE}Available in '$SUBCMD':${NC}"
        MATCHES=$(echo "$TREE_DATA" | grep "^registry/$SUBCMD/")
        if [ -z "$MATCHES" ]; then
            echo -e "${YELLOW}No technologies found in category '$SUBCMD'.${NC}"
        else
            echo "$MATCHES" | awk -F'/' '{print "  - "$NF}' | sed 's/\.md//' | sort
        fi
    fi

else
    echo -e "${BLUE}Searching of '${TARGET}.md' with GitHub API...${NC}"
    
    TREE_DATA=$(curl -s "$API_URL" | grep -o '"path": "[^"]*\.md"' | awk -F'"' '{print $4}' | grep '^registry/')
    
    FILE_PATH=$(echo "$TREE_DATA" | grep -E "/${TARGET}\.md$")
    
    if [ -n "$FILE_PATH" ]; then
        FIRST_MATCH=$(echo "$FILE_PATH" | head -n 1)
        
        LOCAL_DIR=$(dirname "$FIRST_MATCH")
        mkdir -p "$LOCAL_DIR"
        
        DOWNLOAD_URL="$BASE_RAW_URL/$FIRST_MATCH"
        
        if curl -s -f "$DOWNLOAD_URL" -o "$FIRST_MATCH"; then
            echo -e "${GREEN}✔ Rule '$TARGET' sucessfully downloaded into '$LOCAL_DIR/'.${NC}"
        else
            echo -e "${RED}✖ Failed to download '$TARGET'.${NC}"
        fi
    else
        echo -e "${RED}Error: Rule '$TARGET' not found on the remote repository.${NC}"
    fi
fi
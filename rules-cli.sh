#!/bin/bash

REPO_USER="Qua-9-9-1"
REPO_NAME="My-AI-rules"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH/registry"
API_URL="https://api.github.com/repos/$REPO_USER/$REPO_NAME/git/trees/$BRANCH?recursive=1"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

TARGET=$(echo "$1" | tr '[:upper:]' '[:lower:]')
SUBCMD=$(echo "$2" | tr '[:upper:]' '[:lower:]')

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
        URL="$BASE_URL/core/$FILE.md"
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
        echo -e "${BLUE}Available technologies:${NC}"
        echo "$TREE_DATA" | grep -v '^registry/core/' | awk -F'/' '{printf "  %-20s [%s]\n", $3, $2}' | sed 's/\.md//' | sort
    else
        echo -e "${BLUE}Available in '$SUBCMD':${NC}"
        MATCHES=$(echo "$TREE_DATA" | grep "^registry/$SUBCMD/")
        if [ -z "$MATCHES" ]; then
            echo -e "${YELLOW}No technologies found in category '$SUBCMD'.${NC}"
        else
            echo "$MATCHES" | awk -F'/' '{print "  - "$3}' | sed 's/\.md//' | sort
        fi
    fi

else
    CATEGORIES=("languages" "frameworks" "architectures" "infrastructure")
    FOUND=false

    for CAT in "${CATEGORIES[@]}"; do
        URL="$BASE_URL/$CAT/$TARGET.md"
        
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
        
        if [ "$HTTP_CODE" -eq 200 ]; then
            mkdir -p "registry/$CAT"
            curl -s "$URL" -o "registry/$CAT/$TARGET.md"
            echo -e "${GREEN}Downloaded '$TARGET.md' into 'registry/$CAT/'.${NC}"
            FOUND=true
            break
        fi
    done

    if [ "$FOUND" = false ]; then
        echo -e "${RED}Error: Rule '$TARGET' not found on the remote repository.${NC}"
    fi
fi
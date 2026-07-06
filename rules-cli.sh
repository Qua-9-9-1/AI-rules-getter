#!/bin/bash

# Repository Configuration
REPO_USER="Qua-9-9-1"
REPO_NAME="My-AI-rules"
BRANCH="main"

# The Encrypted GitHub Token (Replace with your OpenSSL output)
ENCRYPTED_TOKEN="U2FsdGVkX18+1xX7mqceOD2CkcjitLG0upQD9th5sa5K9lhmHIgg4C+J0zATcRZw
PvN72PPNOedXPsx7Cw65Jw=="

BASE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH/registry"
API_URL="https://api.github.com/repos/$REPO_USER/$REPO_NAME/contents/registry"

AI_DIR=".ai"
TARGET_FILE="$AI_DIR/rules.md"
AGENTS_FILE="$AI_DIR/agents.md"
CONTEXT_DIR="$AI_DIR/context"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CMD=$1
PARAM1=$2
PARAM2=$3

# Function to decrypt the token securely into memory
get_token() {
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${BLUE}Private Repository Access requires decryption.${NC}"
        read -s -p "Enter Vault Password: " VAULT_PASS
        echo ""
        
        GITHUB_TOKEN=$(echo "$ENCRYPTED_TOKEN" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -pass pass:"$VAULT_PASS" 2>/dev/null)
        
        if [ -z "$GITHUB_TOKEN" ] || [[ "$GITHUB_TOKEN" != ghp_* ]] && [[ "$GITHUB_TOKEN" != github_pat_* ]]; then
            echo -e "${RED}Error: Incorrect password or corrupted token.${NC}"
            exit 1
        fi
    fi
}

case $CMD in
    "init")
        get_token
        mkdir -p "$CONTEXT_DIR"
        > "$TARGET_FILE"
        touch "$AGENTS_FILE"
        
        CORE_FILES=("architecture" "git-workflow" "tests" "docs" "security")
        
        for FILE in "${CORE_FILES[@]}"; do
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "$BASE_URL/core/$FILE.md")
            if [ "$HTTP_CODE" -eq 200 ]; then
                curl -s -H "Authorization: token $GITHUB_TOKEN" "$BASE_URL/core/$FILE.md" >> "$TARGET_FILE"
                printf "\n\n" >> "$TARGET_FILE"
            fi
        done
        
        if [ -f ".gitignore" ]; then
            if ! grep -q ".ai/" ".gitignore"; then
                printf "\n.ai/\n" >> .gitignore
            fi
        else
            printf ".ai/\n" > .gitignore
        fi
        
        echo -e "${GREEN}Environment initialized successfully.${NC}"
        ;;
        
    "add")
        if [ -z "$PARAM1" ]; then
            echo -e "${RED}Error: Missing rule name.${NC}"
            exit 1
        fi
        
        get_token
        CATEGORIES=("languages" "frameworks" "architectures" "infrastructure")
        FOUND=false
        
        for CAT in "${CATEGORIES[@]}"; do
            URL="$BASE_URL/$CAT/$PARAM1.md"
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "$URL")
            
            if [ "$HTTP_CODE" -eq 200 ]; then
                curl -s -H "Authorization: token $GITHUB_TOKEN" "$URL" >> "$TARGET_FILE"
                printf "\n\n" >> "$TARGET_FILE"
                echo -e "${GREEN}Rule '${PARAM1}' added from ${CAT}.${NC}"
                FOUND=true
                break
            fi
        done
        
        if [ "$FOUND" = false ]; then
            echo -e "${RED}Error: Rule '${PARAM1}' not found in remote private registry.${NC}"
        fi
        ;;

    "publish")
        if [ -z "$PARAM1" ] || [ -z "$PARAM2" ]; then
            echo -e "${RED}Error: Usage -> rule publish <local_file.md> <category>${NC}"
            exit 1
        fi
        
        if [ ! -f "$PARAM1" ]; then
            echo -e "${RED}Error: File '$PARAM1' does not exist.${NC}"
            exit 1
        fi

        get_token
        FILE_NAME=$(basename "$PARAM1")
        B64_CONTENT=$(base64 < "$PARAM1" | tr -d '\n')
        JSON_PAYLOAD="{\"message\":\"Add $FILE_NAME via CLI\",\"content\":\"$B64_CONTENT\",\"branch\":\"$BRANCH\"}"
        TARGET_API_URL="$API_URL/$PARAM2/$FILE_NAME"

        RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "$JSON_PAYLOAD" \
            "$TARGET_API_URL")

        if [ "$RESPONSE_CODE" -eq 201 ]; then
            echo -e "${GREEN}Successfully published '$FILE_NAME' to remote registry ($PARAM2).${NC}"
        elif [ "$RESPONSE_CODE" -eq 422 ]; then
            echo -e "${YELLOW}Warning: File might already exist (Update not supported in this script).${NC}"
        else
            echo -e "${RED}Error: Failed to publish file. HTTP Code: $RESPONSE_CODE${NC}"
        fi
        ;;
        
    "list")
        get_token
        TREE_URL="https://api.github.com/repos/$REPO_USER/$REPO_NAME/git/trees/$BRANCH?recursive=1"
        echo -e "${BLUE}Available remote rules in private registry:${NC}"
        curl -s -H "Authorization: token $GITHUB_TOKEN" "$TREE_URL" | grep -o '"path": "[^"]*\.md"' | awk -F'"' '{print $4}' | grep '^registry/' | sed 's/registry\///' | sort
        ;;
        
    *)
        echo "Commands:"
        echo "  rule init"
        echo "  rule add <rule_name>"
        echo "  rule publish <local_file_path> <category>"
        echo "  rule list"
        ;;
esac
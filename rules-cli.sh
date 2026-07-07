#!/bin/bash

REPO_USER="Qua-9-9-1"
REPO_NAME="My-AI-rules"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH/registry"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CMD=$1

TARGET=$(echo "$CMD" | tr '[:upper:]' '[:lower:]')

if [ -z "$TARGET" ]; then
    echo -e "${RED}Erreur : Précise 'init' ou le nom d'une technologie (ex: rust).${NC}"
    exit 1
fi

if [ "$TARGET" = "init" ]; then
    echo -e "${GREEN}Initialisation de l'environnement IA...${NC}"

    mkdir -p context
    echo -e " ✔ Dossier 'context/' créé."

    if [ ! -f "AGENTS.md" ]; then
        touch AGENTS.md
        echo -e " ✔ Fichier 'AGENTS.md' créé."
    else
        echo -e " ${YELLOW}ℹ Fichier 'AGENTS.md' existe déjà. Ignoré.${NC}"
    fi

    mkdir -p registry/core
    CORE_FILES=("architecture" "git-workflow" "tests" "docs" "security")
    
    for FILE in "${CORE_FILES[@]}"; do
        URL="$BASE_URL/core/$FILE.md"
        if curl -s -f "$URL" -o "registry/core/$FILE.md"; then
            echo -e " ✔ Téléchargé : registry/core/$FILE.md"
        else
            echo -e " ${RED}✖ Échec du téléchargement : $FILE.md${NC}"
        fi
    done

    # if [ -f ".gitignore" ]; then
    #     grep -q "^context/$" .gitignore || echo "context/" >> .gitignore
    #     grep -q "^AGENTS.md$" .gitignore || echo "AGENTS.md" >> .gitignore
    # else
    #     echo -e "context/\nAGENTS.md" > .gitignore
    # fi
    
    echo -e "${GREEN}Terminé.${NC}"

else
    CATEGORIES=("languages" "frameworks" "architectures" "infrastructure")
    FOUND=false

    for CAT in "${CATEGORIES[@]}"; do
        URL="$BASE_URL/$CAT/$TARGET.md"

        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
        
        if [ "$HTTP_CODE" -eq 200 ]; then
            mkdir -p "registry/$CAT"
            curl -s "$URL" -o "registry/$CAT/$TARGET.md"
            echo -e "${GREEN}✔ Fichier '$TARGET.md' téléchargé dans 'registry/$CAT/'.${NC}"
            FOUND=true
            break
        fi
    done

    if [ "$FOUND" = false ]; then
        echo -e "${RED}Erreur : La règle '$TARGET' est introuvable sur le dépôt public.${NC}"
    fi
fi
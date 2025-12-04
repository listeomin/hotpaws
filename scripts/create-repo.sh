#!/bin/bash

# Create GitHub repository via API

TOKEN="YOUR_GITHUB_TOKEN_HERE"
USERNAME="listeomin"
REPO_NAME="hotpaws"

echo "🐾 Creating GitHub repository..."

# Create repository
curl -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"macOS overlay app for terminal command hints\",
    \"private\": false,
    \"has_issues\": true,
    \"has_projects\": true,
    \"has_wiki\": false,
    \"auto_init\": false
  }"

echo ""
echo "✅ Repository created!"
echo "🔗 https://github.com/$USERNAME/$REPO_NAME"

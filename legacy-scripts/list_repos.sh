#!/bin/bash

# Simple script to list all git repositories found
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)

echo "Searching for Git repositories..."

for dir in "${REPOS_ROOT_DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "Checking directory: $dir"
    while IFS= read -r repo; do
      if [[ -n "$repo" ]]; then
        echo "Found repository: $repo"
        cd "$repo" 2>/dev/null && git status -uno | grep 'Your branch' || echo "  No branch status"
        echo ""
      fi
    done < <(find "$dir" -maxdepth 2 -name ".git" -type d -exec dirname {} \; 2>/dev/null)
  else
    echo "Directory does not exist: $dir"
  fi
done
#!/bin/bash

# Shared Git Utilities
# Common functions used by all git monitoring scripts

# Configuration - central place for all repo discovery settings
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)

# Function to find all git repositories
find_git_repos() {
  local repos=()
  for dir in "${REPOS_ROOT_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      while IFS= read -r -d '' gitdir; do
        if [[ -n "$gitdir" ]]; then
          # Get the parent directory of .git
          repo="${gitdir%/.git}"
          repos+=("$repo")
        fi
      done < <(find "$dir" -maxdepth 2 -name ".git" -type d -print0 2>/dev/null)
    fi
  done
  printf "%s\n" "${repos[@]}"
}

# Function to check if a repo needs pulling
repo_needs_pull() {
  local repo="$1"
  if [[ ! -d "$repo" ]]; then
    return 1
  fi
  
  # Use subshell to avoid changing the working directory
  (
    cd "$repo" || return 1
    
    # Fetch updates from remote (optional)
    if [[ "${SKIP_FETCH:-false}" == "false" ]]; then
      # Try to fetch with a longer timeout for reliability
      timeout 15s git fetch --quiet 2>/dev/null || true
    fi
    
    # Check if branch is behind or diverged
    git status -uno | grep -q -E 'Your branch is behind|have diverged' && return 0 || return 1
  )
}
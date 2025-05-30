#!/bin/bash

# Git Repository Monitor
# Checks local git repositories against their remotes and outputs status for BTT

# Configuration
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)  # Add all directories that contain your git repos
SKIP_FETCH=true  # Set to false if you want to fetch updates from remote
MAX_REPOS=15     # Maximum number of repositories to check

# Colors
TEXT_COLOR_UP_TO_DATE="0,200,0,255"    # Green for up-to-date icon
TEXT_COLOR_NEEDS_PULL="255,103,0,255"  # Orange for needs-pull icon

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
    if [[ "$SKIP_FETCH" == "false" ]]; then
      # Try to fetch with a timeout, but continue even if it fails
      timeout 3s git fetch --quiet 2>/dev/null || true
    fi
    
    # Check if branch is behind or diverged
    git status -uno | grep -q -E 'Your branch is behind|have diverged' && return 0 || return 1
  )
}

# Generate BTT JSON output
generate_btt_json() {
  local text="$1"
  local text_color="$2"
  
  # Create JSON with proper escaping - with transparent background
  local json="{\"text\":\"$text\", \"font_color\":\"$text_color\"}"
  
  # Output the JSON
  echo "$json"
}

# Main function
main() {
  # Set a default output in case script times out
  trap 'generate_btt_json "⏱️" "$TEXT_COLOR_NEEDS_PULL"; exit 0' TERM INT
  
  local needs_pull=()
  local count=0
  
  # Read repositories one per line
  while IFS= read -r repo; do
    # Skip if we've checked too many repos already
    if [[ $count -ge $MAX_REPOS ]]; then
      break
    fi
    
    if repo_needs_pull "$repo" 2>/dev/null; then
      repo_name=$(basename "$repo")
      needs_pull+=("$repo_name")
    fi
    
    ((count++))
  done < <(find_git_repos)
  
  # Generate output for BTT
  if [[ ${#needs_pull[@]} -eq 0 ]]; then
    generate_btt_json "✅" "$TEXT_COLOR_UP_TO_DATE"
  else
    generate_btt_json "⬇️ ${#needs_pull[@]}" "$TEXT_COLOR_NEEDS_PULL"
  fi
}

# Run the script
main 2>/dev/null
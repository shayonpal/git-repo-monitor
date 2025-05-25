#!/bin/bash

# Git Repository Monitor - Debug Version
# Checks local git repositories against their remotes and outputs status for BTT

# Configuration
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Projects"
  "$HOME/Documents"
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)  # Add all directories that contain your git repos

# Colors
TEXT_COLOR_UP_TO_DATE="0,200,0,255"    # Green for up-to-date icon
TEXT_COLOR_NEEDS_PULL="255,103,0,255"  # Orange for needs-pull icon

# Function to find all git repositories
find_git_repos() {
  local repos=()
  for dir in "${REPOS_ROOT_DIRS[@]}"; do
    echo "DEBUG: Checking directory: $dir" >&2
    if [[ -d "$dir" ]]; then
      while IFS= read -r repo; do
        echo "DEBUG: Found repository: $repo" >&2
        repos+=("$repo")
      done < <(find "$dir" -name ".git" -type d -maxdepth 3 -exec dirname {} \; 2>/dev/null)
    else
      echo "DEBUG: Directory does not exist: $dir" >&2
    fi
  done
  echo "${repos[@]}"
}

# Function to check if a repo needs pulling
repo_needs_pull() {
  local repo="$1"
  echo "DEBUG: Checking if repo needs pulling: $repo" >&2
  
  if [[ ! -d "$repo" ]]; then
    echo "DEBUG: Repository directory does not exist: $repo" >&2
    return 1
  fi
  
  cd "$repo" || { echo "DEBUG: Failed to cd to $repo" >&2; return 1; }
  
  # Fetch updates from remote without merging
  echo "DEBUG: Running git fetch for $repo" >&2
  git fetch --quiet 2>/dev/null || { echo "DEBUG: git fetch failed for $repo" >&2; return 1; }
  
  # Check if local is behind remote
  local behind_count=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
  echo "DEBUG: Behind count for $repo: $behind_count" >&2
  
  # Return true (0) if behind, false (1) if up-to-date
  [[ "$behind_count" -gt 0 ]]
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
  # Store IFS to restore it later
  local oldIFS="$IFS"
  IFS=$'\n'
  
  echo "DEBUG: Starting repository search" >&2
  local repos=($(find_git_repos))
  local needs_pull=()
  local error_repos=()
  
  echo "DEBUG: Found ${#repos[@]} repositories" >&2
  
  for repo in "${repos[@]}"; do
    if [[ -d "$repo" ]]; then
      if repo_needs_pull "$repo"; then
        repo_name=$(basename "$repo")
        echo "DEBUG: Repository needs pulling: $repo_name" >&2
        needs_pull+=("$repo_name")
      fi
    else
      echo "DEBUG: Repository no longer exists: $repo" >&2
    fi
  done
  
  # Restore IFS
  IFS="$oldIFS"
  
  echo "DEBUG: Repositories needing pull: ${#needs_pull[@]}" >&2
  if [[ ${#needs_pull[@]} -gt 0 ]]; then
    echo "DEBUG: Repos needing pull: ${needs_pull[*]}" >&2
  fi
  
  # Generate output for BTT
  if [[ ${#needs_pull[@]} -eq 0 ]]; then
    generate_btt_json "✅" "$TEXT_COLOR_UP_TO_DATE"
  else
    generate_btt_json "⬇️ ${#needs_pull[@]}" "$TEXT_COLOR_NEEDS_PULL"
  fi
}

# Run the script
main 2>/tmp/git_monitor_debug.log
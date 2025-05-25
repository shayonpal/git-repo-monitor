#!/bin/bash

# Git Repository Monitor - No Fetch Version
# Checks local git repositories against their remotes WITHOUT fetching

# Configuration
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)  # Add all directories that contain your git repos

# Colors
TEXT_COLOR_UP_TO_DATE="0,200,0,255"    # Green for up-to-date icon
TEXT_COLOR_NEEDS_PULL="255,103,0,255"  # Orange for needs-pull icon

# Function to find all git repositories
find_git_repos() {
  local repos=()
  for dir in "${REPOS_ROOT_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "DEBUG: Checking directory: $dir" >&2
      while IFS= read -r repo; do
        if [[ -n "$repo" ]]; then
          echo "DEBUG: Found repository: $repo" >&2
          repos+=("$repo")
        fi
      done < <(find "$dir" -name ".git" -type d -maxdepth 2 -exec dirname {} \; 2>/dev/null)
    else
      echo "DEBUG: Directory does not exist: $dir" >&2
    fi
  done
  for repo in "${repos[@]}"; do
    echo "$repo"
  done
}

# Function to check if a repo needs pulling WITHOUT fetching
repo_needs_pull() {
  local repo="$1"
  echo "DEBUG: Checking repo: $repo" >&2
  
  if [[ ! -d "$repo" ]]; then
    echo "DEBUG: Directory does not exist: $repo" >&2
    return 1
  fi
  
  # Change to the repository directory
  cd "$repo" || { echo "DEBUG: Failed to cd to $repo" >&2; return 1; }
  
  # Skip fetch and just check status
  local status=$(git status -uno)
  echo "DEBUG: Git status for $repo:" >&2
  echo "$status" >&2
  echo "DEBUG: Grepping for 'behind' or 'diverged'" >&2
  echo "$status" | grep -q -E 'Your branch is behind|have diverged' && {
    echo "DEBUG: $repo needs pull" >&2
    echo "$status" | grep -E 'Your branch is behind|have diverged' >&2
    return 0
  } || {
    echo "DEBUG: $repo is up to date" >&2
    return 1
  }
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
  echo "DEBUG: Starting repository check" >&2
  local needs_pull=()
  local count=0
  local max_repos=10  # Limit how many repos to check
  
  # Find all repositories
  local repos=()
  while IFS= read -r repo; do
    if [[ -n "$repo" ]]; then
      repos+=("$repo")
    fi
  done < <(find_git_repos)
  
  echo "DEBUG: Found ${#repos[@]} repositories to check" >&2
  
  # Check each repository
  for repo in "${repos[@]}"; do
    # Skip if we've checked too many repos already
    if [ $count -ge $max_repos ]; then
      echo "DEBUG: Reached max repo check limit ($max_repos)" >&2
      break
    fi
    
    if repo_needs_pull "$repo"; then
      repo_name=$(basename "$repo")
      echo "DEBUG: Adding $repo_name to needs_pull list" >&2
      needs_pull+=("$repo_name")
    fi
    
    ((count++))
  done
  
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
main 2>/tmp/git_monitor_nofetch.log
#!/bin/bash

# Git Repository Monitor
# Checks local git repositories against their remotes and outputs status for BTT

# Source shared utilities
source "$(dirname "$0")/git_utils.sh"

# Configuration
SKIP_FETCH=false  # Set to true if you want to skip fetching updates from remote
MAX_REPOS=15     # Maximum number of repositories to check

# Colors
TEXT_COLOR_UP_TO_DATE="0,200,0,255"    # Green for up-to-date icon
TEXT_COLOR_NEEDS_PULL="255,103,0,255"  # Orange for needs-pull icon

# Functions are now sourced from git_utils.sh

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
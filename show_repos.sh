#!/bin/bash

# Click handler script for Git Repository Monitor
# Shows repos needing updates and allows navigation to them

# Configuration
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)  # Add all directories that contain your git repos
SKIP_FETCH=true  # Set to false if you want to fetch updates from remote
TERMINAL_APP="Terminal"  # Options: Terminal, iTerm, etc.

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
  ) 2>/dev/null
}

# Function to get status description for a repo
get_repo_status() {
  local repo="$1"
  
  # Use subshell to avoid changing the working directory
  (
    cd "$repo" || return 1
    
    local status_text=$(git status -uno | grep -E 'Your branch is behind|have diverged')
    
    if [[ $status_text == *"behind"* ]]; then
      echo "$status_text" | sed -E 's/.*behind .* by ([0-9]+) commit.*/\1 commits behind/'
    elif [[ $status_text == *"diverged"* ]]; then
      echo "branches have diverged"
    else
      echo "needs attention"
    fi
  ) 2>/dev/null
}

# Function to open repo in Finder
open_in_finder() {
  local repo="$1"
  open -a Finder "$repo"
}

# Function to open repo in Terminal
open_in_terminal() {
  local repo="$1"
  
  if [[ "$TERMINAL_APP" == "iTerm" ]]; then
    # Open in iTerm
    osascript -e "tell application \"iTerm\"
      create window with default profile
      tell current session of current window
        write text \"cd $repo && clear && git status\"
      end tell
    end tell"
  else
    # Open in Terminal.app (default)
    osascript -e "tell application \"Terminal\"
      do script \"cd $repo && clear && git status\"
      activate
    end tell"
  fi
}

# Function to pull the repository
pull_repo() {
  local repo="$1"
  
  # Use subshell to avoid changing the working directory
  (
    cd "$repo" || return 1
    git pull
  )
  echo "Pulled updates for $(basename "$repo")"
  echo "Press Enter to continue..."
  read -r
}

# Main function
main() {
  local needs_pull=()
  
  # Read repositories one per line
  while IFS= read -r repo; do
    if [[ -d "$repo" ]] && repo_needs_pull "$repo" 2>/dev/null; then
      needs_pull+=("$repo")
    fi
  done < <(find_git_repos)
  
  # If no repos need pulling, show a notification and exit
  if [[ ${#needs_pull[@]} -eq 0 ]]; then
    echo "✅ All repositories are up to date!"
    osascript -e 'display notification "All repositories are up to date!" with title "Git Repository Monitor"'
    exit 0
  fi
  
  # Create a simple text-based menu instead of HTML
  clear
  echo "=== Git Repositories Needing Updates ==="
  echo ""
  
  local i=1
  for repo in "${needs_pull[@]}"; do
    repo_name=$(basename "$repo")
    status=$(get_repo_status "$repo")
    echo "$i) $repo_name ($status)"
    echo "   Path: $repo"
    echo ""
    i=$((i+1))
  done
  
  echo "Choose an option:"
  echo "f) Open a repository in Finder"
  echo "t) Open a repository in Terminal"
  echo "p) Pull updates for a repository"
  echo "q) Quit"
  echo ""
  read -p "Enter your choice: " choice
  
  case $choice in
    f)
      read -p "Enter repository number: " repo_num
      if [[ $repo_num -ge 1 && $repo_num -le ${#needs_pull[@]} ]]; then
        open_in_finder "${needs_pull[$repo_num-1]}"
      fi
      ;;
    t)
      read -p "Enter repository number: " repo_num
      if [[ $repo_num -ge 1 && $repo_num -le ${#needs_pull[@]} ]]; then
        open_in_terminal "${needs_pull[$repo_num-1]}"
      fi
      ;;
    p)
      read -p "Enter repository number: " repo_num
      if [[ $repo_num -ge 1 && $repo_num -le ${#needs_pull[@]} ]]; then
        pull_repo "${needs_pull[$repo_num-1]}"
      fi
      ;;
    q)
      exit 0
      ;;
  esac
}

# Parse command-line arguments
if [[ "$1" == "--open-finder" ]]; then
  open_in_finder "$2"
  exit 0
elif [[ "$1" == "--open-terminal" ]]; then
  open_in_terminal "$2"
  exit 0
elif [[ "$1" == "--pull" ]]; then
  pull_repo "$2"
  exit 0
else
  # Run main function
  main
fi
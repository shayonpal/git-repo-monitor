#!/bin/bash

# Debug script to understand the issue

echo "=== Testing find command ==="
echo "Finding .git directories:"
find "$HOME/DevProjects" -maxdepth 2 -name ".git" -type d | head -5

echo -e "\n=== Testing dirname on .git directories ==="
find "$HOME/DevProjects" -maxdepth 2 -name ".git" -type d -exec dirname {} \; | head -5

echo -e "\n=== Testing repo_needs_pull function ==="
source ./git_monitor.sh

# Test with a known git repo
test_repo="$HOME/DevProjects/git-repo-monitor"
echo "Testing with: $test_repo"
echo "Is directory: $([ -d "$test_repo" ] && echo "YES" || echo "NO")"
echo "Has .git: $([ -d "$test_repo/.git" ] && echo "YES" || echo "NO")"

# Run in subshell to see output
(
  cd "$test_repo" || exit 1
  echo "Current directory: $(pwd)"
  echo "Git status output:"
  git status -uno
  echo "Checking pattern:"
  if git status -uno | grep -q -E 'Your branch is behind|have diverged'; then
    echo "NEEDS PULL"
  else
    echo "UP TO DATE"
  fi
)

echo -e "\n=== Testing find_git_repos function ==="
repos=($(find_git_repos))
echo "Found ${#repos[@]} repositories"
echo "First 5:"
for i in {0..4}; do
  [ -n "${repos[$i]}" ] && echo "  - ${repos[$i]}"
done

echo -e "\n=== Checking non-git directories ==="
echo "Directories being checked as repos that aren't git repos:"
for repo in "${repos[@]}"; do
  if [ ! -d "$repo/.git" ]; then
    echo "  - $repo (NOT A GIT REPO)"
  fi
done
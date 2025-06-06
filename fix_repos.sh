#!/bin/bash

# Fix Repository Issues - Auto-pull repos that are behind remote
# Used by the git monitoring workflow

echo "Auto-fixing Repository Issues"
echo "============================="

fixed_count=0

# Source shared utilities
source "$(dirname "$0")/git_utils.sh"

# Find all git repositories
while IFS= read -r dir; do
    if [[ -n "$dir" && -d "$dir/.git" ]]; then
        repo_name=$(basename "$dir")
        cd "$dir"
        
        # Fetch latest
        git fetch --quiet 2>/dev/null || true
        
        # If behind or diverged and working tree is clean, auto-pull
        if git status -uno | grep -q -E "Your branch is behind|have diverged"; then
            if git diff-index --quiet HEAD -- 2>/dev/null && [[ -z $(git ls-files --others --exclude-standard) ]]; then
                echo "Pulling updates for $repo_name..."
                if git pull --rebase --quiet; then
                    echo "  Successfully updated $repo_name"
                    ((fixed_count++))
                else
                    echo "  Failed to update $repo_name"
                fi
            else
                echo "Skipping $repo_name - has uncommitted changes"
                echo "  Files changed:"
                git status -sbu | head -5
                if [[ $(git status -sbu | wc -l) -gt 5 ]]; then
                    echo "  ... and $(( $(git status -sbu | wc -l) - 5 )) more files"
                fi
                echo ""
                read -p "  Enter commit message (or press Enter for 'Update uncommitted changes'): " commit_msg
                if [[ -z "$commit_msg" ]]; then
                    commit_msg="Update uncommitted changes"
                fi
                
                echo "  Committing changes..."
                if git add . && git commit -m "$commit_msg"; then
                    echo "  Changes committed. Now pulling updates..."
                    if git pull --rebase --quiet; then
                        echo "  Successfully updated $repo_name"
                        ((fixed_count++))
                    else
                        echo "  Failed to pull after commit"
                    fi
                else
                    echo "  Failed to commit changes"
                fi
            fi
        fi
        
        cd - > /dev/null
    fi
done < <(find_git_repos)

echo ""
if [[ $fixed_count -gt 0 ]]; then
    echo "Fixed $fixed_count repositories"
else
    echo "No repositories needed fixing"
fi

echo ""
read -p "Press Enter to continue..."
#!/bin/bash

# Interactive Git Repository Menu
# Shows repos that need updates and provides action options

echo "=== Git Repositories Needing Updates ==="
echo ""

# Source shared utilities
source "$(dirname "$0")/git_utils.sh"

# Find repos that are behind
behind_repos=()
repo_paths=()

while IFS= read -r dir; do
    if [[ -n "$dir" && -d "$dir/.git" ]]; then
        repo_name=$(basename "$dir")
        cd "$dir"
        
        # Fetch quietly
        git fetch --quiet 2>/dev/null || true
        
        # Check if behind or diverged
        if git status -uno | grep -q -E "Your branch is behind|have diverged"; then
            if git status -uno | grep -q "Your branch is behind"; then
                behind_count=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "?")
                behind_repos+=("$repo_name ($behind_count commits behind)")
            else
                behind_repos+=("$repo_name (diverged - needs merge)")
            fi
            repo_paths+=("$dir")
        fi
        
        cd - > /dev/null
    fi
done < <(find_git_repos)

# Check if any repos need updates
if [[ ${#behind_repos[@]} -eq 0 ]]; then
    echo "All repositories are up to date!"
    echo ""
    read -p "Press Enter to close..."
    exit 0
fi

# Display repos that need updates
for i in "${!behind_repos[@]}"; do
    echo "$((i+1))) ${behind_repos[i]}"
    echo "   Path: ${repo_paths[i]}"
    echo ""
done

echo "Choose an option:"
echo "t) Open a repository in Terminal (iTerm2)"
echo "c) Open a repository in Cursor IDE"  
echo "z) Open a repository in Zed IDE"
echo "p) Pull updates for a specific repository"
echo "a) Pull updates for ALL repositories"
echo "q) Quit"
echo ""

# Function to pull updates for a specific repo
pull_single_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    
    cd "$repo_path"
    
    echo "Updating $repo_name..."
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null || [[ -n $(git ls-files --others --exclude-standard) ]]; then
        echo "Repository has uncommitted changes:"
        git status -sbu | head -10
        if [[ $(git status -sbu | wc -l) -gt 10 ]]; then
            echo "... and $(( $(git status -sbu | wc -l) - 10 )) more files"
        fi
        echo ""
        
        read -p "Enter commit message (or press Enter for 'Update uncommitted changes'): " commit_msg
        if [[ -z "$commit_msg" ]]; then
            commit_msg="Update uncommitted changes"
        fi
        
        echo "Committing changes..."
        if git add . && git commit -m "$commit_msg"; then
            echo "Changes committed successfully"
        else
            echo "Failed to commit changes"
            cd - > /dev/null
            return 1
        fi
    fi
    
    echo "Pulling updates..."
    if git pull --rebase --quiet; then
        echo "Successfully updated $repo_name"
        cd - > /dev/null
        return 0
    else
        echo "Failed to pull updates for $repo_name"
        echo "You may need to resolve conflicts manually"
        cd - > /dev/null
        return 1
    fi
}

while true; do
    read -p "Enter your choice: " choice
    
    case $choice in
        [1-9]*)
            # Check if number is valid
            if [[ $choice -le ${#behind_repos[@]} && $choice -ge 1 ]]; then
                selected_path="${repo_paths[$((choice-1))]}"
                echo ""
                echo "Selected: ${behind_repos[$((choice-1))]}"
                echo "Path: $selected_path"
                echo ""
                echo "How would you like to open it?"
                echo "t) Terminal (iTerm2)"
                echo "c) Cursor IDE"
                echo "z) Zed IDE"
                echo "p) Pull updates for this repository"
                read -p "Enter choice: " open_choice
                
                case $open_choice in
                    t)
                        osascript -e "
                        tell application \"iTerm2\"
                            tell current window
                                create tab with default profile
                                tell current session
                                    write text \"cd '$selected_path'\"
                                end tell
                            end tell
                        end tell"
                        echo "Opened in iTerm2"
                        ;;
                    c)
                        cd "$selected_path" && cursor . &
                        echo "Opened in Cursor IDE"
                        ;;
                    z)
                        cd "$selected_path" && zed . &
                        echo "Opened in Zed IDE"
                        ;;
                    p)
                        pull_single_repo "$selected_path"
                        ;;
                    *)
                        echo "Invalid choice"
                        continue
                        ;;
                esac
            else
                echo "Invalid repository number"
                continue
            fi
            ;;
        t)
            echo ""
            echo "Select repository to open in Terminal:"
            for i in "${!behind_repos[@]}"; do
                echo "$((i+1))) ${behind_repos[i]}"
            done
            read -p "Enter repository number: " repo_num
            
            if [[ $repo_num -le ${#behind_repos[@]} && $repo_num -ge 1 ]]; then
                selected_path="${repo_paths[$((repo_num-1))]}"
                osascript -e "
                tell application \"iTerm2\"
                    tell current window
                        create tab with default profile
                        tell current session
                            write text \"cd '$selected_path'\"
                        end tell
                    end tell
                end tell"
                echo "Opened ${behind_repos[$((repo_num-1))]} in iTerm2"
            else
                echo "Invalid repository number"
                continue
            fi
            ;;
        c)
            echo ""
            echo "Select repository to open in Cursor IDE:"
            for i in "${!behind_repos[@]}"; do
                echo "$((i+1))) ${behind_repos[i]}"
            done
            read -p "Enter repository number: " repo_num
            
            if [[ $repo_num -le ${#behind_repos[@]} && $repo_num -ge 1 ]]; then
                selected_path="${repo_paths[$((repo_num-1))]}"
                cd "$selected_path" && cursor . &
                echo "Opened ${behind_repos[$((repo_num-1))]} in Cursor IDE"
            else
                echo "Invalid repository number"
                continue
            fi
            ;;
        z)
            echo ""
            echo "Select repository to open in Zed IDE:"
            for i in "${!behind_repos[@]}"; do
                echo "$((i+1))) ${behind_repos[i]}"
            done
            read -p "Enter repository number: " repo_num
            
            if [[ $repo_num -le ${#behind_repos[@]} && $repo_num -ge 1 ]]; then
                selected_path="${repo_paths[$((repo_num-1))]}"
                cd "$selected_path" && zed . &
                echo "Opened ${behind_repos[$((repo_num-1))]} in Zed IDE"
            else
                echo "Invalid repository number"
                continue
            fi
            ;;
        p)
            echo ""
            echo "Select repository to pull updates:"
            for i in "${!behind_repos[@]}"; do
                echo "$((i+1))) ${behind_repos[i]}"
            done
            read -p "Enter repository number: " repo_num
            
            if [[ $repo_num -le ${#behind_repos[@]} && $repo_num -ge 1 ]]; then
                selected_path="${repo_paths[$((repo_num-1))]}"
                echo ""
                pull_single_repo "$selected_path"
            else
                echo "Invalid repository number"
                continue
            fi
            ;;
        a)
            echo ""
            echo "Running auto-fix for all repositories..."
            /Users/shayon/DevProjects/automonitor-git-repos/fix_repos.sh
            echo ""
            echo "Update complete!"
            ;;
        q)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    
    echo ""
    echo "Choose another option or 'q' to quit:"
    echo "t) Open a repository in Terminal (iTerm2)"
    echo "c) Open a repository in Cursor IDE"  
    echo "z) Open a repository in Zed IDE"
    echo "p) Pull updates for a specific repository"
    echo "a) Pull updates for ALL repositories"
    echo "q) Quit"
    echo ""
done
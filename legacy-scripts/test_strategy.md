# Git Repository Monitor Testing Strategy

## Overview
This document outlines a systematic approach to test and debug the Git Repository Monitor system.

## 1. Component Testing

### A. Test git_monitor.sh (Core Monitoring Script)

#### Basic Functionality Tests
```bash
# Test 1: Direct execution - check JSON output
./git_monitor.sh
# Expected: JSON output like {"text":"✅", "font_color":"0,200,0,255"} or {"text":"⬇️ N", "font_color":"255,103,0,255"}

# Test 2: Check if script finds repositories
bash -x git_monitor.sh 2>&1 | grep "find.*\.git"
# Expected: See find commands being executed

# Test 3: Test with debug output
cat > test_git_monitor.sh << 'EOF'
#!/bin/bash
source ./git_monitor.sh

# Test find_git_repos function
echo "=== Testing find_git_repos ==="
repos=($(find_git_repos))
echo "Found ${#repos[@]} repositories:"
for repo in "${repos[@]}"; do
    echo "  - $repo"
done

# Test repo_needs_pull function
echo -e "\n=== Testing repo_needs_pull ==="
for repo in "${repos[@]:0:3}"; do
    if repo_needs_pull "$repo"; then
        echo "$repo: NEEDS PULL"
    else
        echo "$repo: UP TO DATE"
    fi
done
EOF
chmod +x test_git_monitor.sh
./test_git_monitor.sh
```

#### Repository Discovery Tests
```bash
# Test 4: Verify repository paths exist
for dir in "$HOME/DevProjects" "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"; do
    echo "Checking: $dir"
    if [[ -d "$dir" ]]; then
        echo "  ✓ Directory exists"
        find "$dir" -name ".git" -type d -maxdepth 2 2>/dev/null | wc -l | xargs echo "  Git repos found:"
    else
        echo "  ✗ Directory NOT found"
    fi
done

# Test 5: Manual repository status check
cd ~/DevProjects/git-repo-monitor
git fetch
git status -uno
# Check if output contains "Your branch is behind" or "have diverged"
```

### B. Test open_in_iterm.scpt (AppleScript)

```bash
# Test 6: Direct AppleScript execution
osascript open_in_iterm.scpt
# Expected: New iTerm tab opens and runs show_repos.sh

# Test 7: Check if show_repos.sh path is correct
ls -la ~/DevProjects/git-repo-monitor/show_repos.sh
# Expected: File exists and is executable
```

### C. Test BetterTouchTool Integration

1. **BTT Widget Configuration Check**:
   - Open BTT preferences
   - Navigate to your Shell Script Widget
   - Verify script path points to git_monitor.sh
   - Check refresh interval (should be ~300 seconds)
   - Verify "Show in menu bar" is checked

2. **BTT Action Configuration**:
   - Click on the widget's action settings
   - Verify it's set to "Run Apple Script File (async)"
   - Check that it points to open_in_iterm.scpt

## 2. Debugging Steps

### Step 1: Isolate JSON Output Issues
```bash
# Create a test script to verify BTT JSON format
cat > test_btt_output.sh << 'EOF'
#!/bin/bash

# Test different JSON outputs
echo "Test 1 - Up to date:"
echo '{"text":"✅", "font_color":"0,200,0,255"}'

echo -e "\nTest 2 - Needs pull:"
echo '{"text":"⬇️ 3", "font_color":"255,103,0,255"}'

echo -e "\nTest 3 - Timeout:"
echo '{"text":"⏱️", "font_color":"255,103,0,255"}'
EOF

chmod +x test_btt_output.sh
./test_btt_output.sh
```

### Step 2: Test Repository Detection
```bash
# Create a script to test repository detection logic
cat > debug_repos.sh << 'EOF'
#!/bin/bash

REPOS_ROOT_DIRS=(
  "$HOME/DevProjects" 
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)"
)

echo "=== Repository Detection Debug ==="
for dir in "${REPOS_ROOT_DIRS[@]}"; do
    echo -e "\nChecking: $dir"
    if [[ -d "$dir" ]]; then
        echo "✓ Directory exists"
        
        # Count .git directories
        git_count=$(find "$dir" -name ".git" -type d -maxdepth 2 2>/dev/null | wc -l)
        echo "  Found $git_count .git directories"
        
        # List first 5 repositories
        echo "  First 5 repositories:"
        find "$dir" -name ".git" -type d -maxdepth 2 -exec dirname {} \; 2>/dev/null | head -5 | while read repo; do
            echo "    - $(basename "$repo")"
            cd "$repo" 2>/dev/null && git remote -v | head -1 | awk '{print "      Remote: " $2}'
        done
    else
        echo "✗ Directory NOT found"
    fi
done
EOF

chmod +x debug_repos.sh
./debug_repos.sh
```

### Step 3: Test Git Status Detection
```bash
# Create a script to test the status detection logic
cat > test_git_status.sh << 'EOF'
#!/bin/bash

# Test the grep pattern used in the script
test_repo="$HOME/DevProjects/git-repo-monitor"

echo "Testing repository: $test_repo"
cd "$test_repo" || exit 1

echo -e "\nGit status output:"
git status -uno

echo -e "\nChecking patterns:"
if git status -uno | grep -q -E 'Your branch is behind|have diverged'; then
    echo "✓ Repository needs pull"
else
    echo "✗ Repository is up to date"
fi

# Test with actual fetch
echo -e "\nTesting with fetch:"
git fetch
git status -uno | grep -E 'Your branch is|have diverged' || echo "No updates needed"
EOF

chmod +x test_git_status.sh
./test_git_status.sh
```

## 3. Common Issues and Solutions

### Issue 1: No repositories found
**Test**: `./git_monitor.sh` returns `{"text":"✅", "font_color":"0,200,0,255"}` even when repos need updates

**Debug**:
```bash
# Check if find command works
find "$HOME/DevProjects" -name ".git" -type d -maxdepth 2 2>/dev/null

# Check permissions
ls -la "$HOME/DevProjects"
```

### Issue 2: Script timeout
**Test**: Menu bar shows ⏱️ icon

**Debug**:
```bash
# Test with extended timeout
SKIP_FETCH=false timeout 10s ./git_monitor.sh

# Check network connectivity
ping -c 1 github.com
```

### Issue 3: iTerm doesn't open
**Test**: Clicking menu bar item does nothing

**Debug**:
```bash
# Test AppleScript directly
osascript -e 'tell application "iTerm2" to activate'

# Check script permissions
ls -la open_in_iterm.scpt
ls -la show_repos.sh
```

### Issue 4: Wrong status displayed
**Test**: Repos show as up-to-date when they're not

**Debug**:
```bash
# Manually check a repository
cd ~/DevProjects/[some-repo]
git fetch
git rev-list HEAD...origin/$(git rev-parse --abbrev-ref HEAD) --count
```

## 4. Performance Testing

```bash
# Time the script execution
time ./git_monitor.sh

# Profile with more detail
bash -x git_monitor.sh 2>&1 | ts '[%Y-%m-%d %H:%M:%.S]'
```

## 5. End-to-End Test

1. Create a test repository that's behind:
```bash
cd ~/DevProjects
git clone https://github.com/octocat/Hello-World.git test-behind
cd test-behind
git reset --hard HEAD~2
```

2. Run git_monitor.sh and verify it shows ⬇️ 1

3. Click the menu bar item and verify iTerm opens with show_repos.sh

4. Clean up:
```bash
rm -rf ~/DevProjects/test-behind
```

## Next Steps

1. Run through each test section systematically
2. Document which tests pass/fail
3. Focus debugging on failed tests
4. Check BTT logs: `~/Library/Logs/BetterTouchTool/`
#!/bin/bash

echo "=== Git Repository Monitor Functionality Test ==="
echo

# Source the script to use its functions
source ./git_monitor.sh

echo "1. Testing repository discovery:"
repos=($(find_git_repos))
echo "   Found ${#repos[@]} repositories"
echo "   First 3 repositories:"
for i in {0..2}; do
    [ -n "${repos[$i]}" ] && echo "   - ${repos[$i]}"
done

echo
echo "2. Testing individual repository status:"
for i in {0..2}; do
    if [ -n "${repos[$i]}" ]; then
        repo="${repos[$i]}"
        echo "   Checking: $(basename "$repo")"
        (
            cd "$repo" 2>/dev/null || exit
            # Show actual git status
            status=$(git status -uno 2>/dev/null | grep -E "Your branch is|have diverged" || echo "Up to date")
            echo "     Status: $status"
            # Test our function
            if repo_needs_pull "$repo" 2>/dev/null; then
                echo "     repo_needs_pull: YES"
            else
                echo "     repo_needs_pull: NO"
            fi
        )
    fi
done

echo
echo "3. Testing full script output:"
echo -n "   Result: "
./git_monitor.sh

echo
echo "4. Testing with manual behind state:"
echo "   Creating test scenario..."
# Create a test repo that's behind
test_dir="/tmp/git-monitor-test-$$"
mkdir -p "$test_dir"
cd "$test_dir"
git init test-repo >/dev/null 2>&1
cd test-repo
echo "test" > file.txt
git add file.txt
git commit -m "Initial commit" >/dev/null 2>&1
echo "test2" > file.txt
git add file.txt
git commit -m "Second commit" >/dev/null 2>&1

# Simulate being behind by resetting
git reset --hard HEAD~1 >/dev/null 2>&1

# Temporarily add this to REPOS_ROOT_DIRS
cd - >/dev/null
cat > test_monitor.sh << EOF
#!/bin/bash
REPOS_ROOT_DIRS=("$test_dir")
SKIP_FETCH=true
MAX_REPOS=15
TEXT_COLOR_UP_TO_DATE="0,200,0,255"
TEXT_COLOR_NEEDS_PULL="255,103,0,255"

$(sed -n '/# Function to find all git repositories/,$p' git_monitor.sh)
EOF

chmod +x test_monitor.sh
echo -n "   Test result (should show needs pull): "
./test_monitor.sh

# Cleanup
rm -rf "$test_dir" test_monitor.sh

echo
echo "=== Test Complete ==="
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "/Users/shayon/DevProjects/git-repo-monitor/show_repos.sh"
        end tell
    end tell
end tell

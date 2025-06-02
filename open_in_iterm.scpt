tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "/Users/shayon/DevProjects/automonitor-git-repos/show_repos.sh"
        end tell
    end tell
end tell

-- Smart Git Repository Manager
-- Only opens iTerm2 if there are repos behind, otherwise shows notification

-- First, check if there are any repos behind without opening iTerm2
set shellScript to "/Users/shayon/DevProjects/automonitor-git-repos/git_monitor.sh"
set gitStatus to do shell script shellScript

-- Parse the JSON output to see if there are any repos behind
if gitStatus contains "✅" then
    -- All repos are up to date, just show notification
    display notification "All repositories are up to date!" with title "Git Repository Status"
else
    -- There are repos behind, open iTerm2 with interactive menu
    tell application "iTerm2"
        activate
        
        -- Check if there are any windows, if not create one
        if (count of windows) is 0 then
            create window with default profile
        end if
        
        tell current window
            create tab with default profile
            tell current session
                write text "/Users/shayon/DevProjects/automonitor-git-repos/interactive_menu.sh"
            end tell
        end tell
        
        -- Bring iTerm2 to front and make the new tab current
        activate
        tell current window
            select
        end tell
    end tell
end if
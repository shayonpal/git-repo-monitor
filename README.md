# Git Repository Monitor

A tool that monitors your local Git repositories and shows which ones need to be pulled through a BetterTouchTool menu bar item.

## Features

- Finds all Git repositories in specified directories
- Compares local branches with their remote counterparts
- Shows a visual indicator in the menu bar when repos need updating
- Displays a terminal interface to manage repositories when clicked

## Setup

### Prerequisites

- macOS
- [BetterTouchTool](https://folivora.ai/)
- [iTerm2](https://iterm2.com/) (recommended)
- Git

### Installation

1. Clone this repository or download the scripts
2. Make the scripts executable (if not already):
   ```bash
   chmod +x git_monitor.sh show_repos.sh
   ```
3. Edit the scripts to configure your repository directories:
   ```bash
   # In both git_monitor.sh and show_repos.sh, modify:
   REPOS_ROOT_DIRS=(
     "$HOME/Projects" 
     "$HOME/Documents/Repositories"
   )
   ```

### BetterTouchTool Configuration

#### Main Status Item

1. Open BetterTouchTool
2. Go to "Automations & Named & Other Triggers" section
3. Click "Add New" and select "Shell Script / Task Widget" under "Automations & Named Triggers"
4. Configure the shell script widget:
   - Name: Git Repos Status
   - Shell Script Path: `/bin/bash`
   - Script: Enter the full path to the monitoring script (e.g., `$HOME/git-repo-monitor/git_monitor.sh`)
   - Refresh Interval: 300 (seconds, adjust as needed)
   - Check "Show in menu bar"
5. Set click action to run the AppleScript (for iTerm2):
   - Under "Assigned Actions", click the "+" button
   - Select "Run Apple Script (async in background)"
   - Enter the following script:
   ```applescript
   tell application "iTerm2"
       tell current window
           create tab with default profile
           tell current session
               write text "$HOME/git-repo-monitor/show_repos.sh"
           end tell
       end tell
   end tell
   ```
   - Or, if you prefer, select "Run Apple Script File (async)" and point to the included `open_in_iterm.scpt` file (update the path in this file first)
6. Click Save

## Visual Indicators

The script provides visual feedback in the menu bar:

- ✅ in green text: All repositories are up-to-date
- ⬇️ with number in orange text: Some repositories need to be pulled
- ⏱️ in orange text: Timeout occurred while checking repositories

## Interaction

When clicking on the menu bar item, an iTerm2 tab will open that:
- Lists all repositories that need updates
- Shows how many commits behind each repository is or if branches have diverged
- Provides options to:
  - Open the repository in Finder
  - Open the repository in Terminal
  - Pull updates for the repository

## Customization

You can customize the scripts by modifying:

- `REPOS_ROOT_DIRS`: Directories to search for Git repositories
- `SKIP_FETCH`: Set to false if you want to fetch updates (may require SSH key setup)
- `MAX_REPOS`: Maximum number of repositories to check (default: 15)
- `maxdepth` value in the find command (currently set to 2)
- Colors in the color variables section of git_monitor.sh
- `TERMINAL_APP` in show_repos.sh to use iTerm instead of Terminal.app
- The AppleScript to customize how iTerm2 opens (new window vs. new tab)

## Troubleshooting

- If no repositories are found, check that your repository directories are correctly specified
- If the script seems slow, consider reducing the maxdepth value in the find command to limit the search depth
- If you're having issues with the git fetch step, keep `SKIP_FETCH=true` in the scripts
- Ensure the scripts have executable permissions
- If iTerm2 doesn't open or gives an error, make sure iTerm2 is installed and the AppleScript syntax is correct
- Make sure to replace `$HOME` in the AppleScript with your actual home directory path if needed
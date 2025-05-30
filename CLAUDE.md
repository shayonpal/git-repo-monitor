# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a script for automatically monitoring local Git repositories and comparing them with their remote counterparts. The script is designed to work with BetterTouchTool to display repository status in the macOS menu bar.

## Development Commands

- Test the main monitoring script: `./git_monitor.sh`
- Run the interactive repository manager: `./show_repos.sh`
- List all found repositories: `./list_repos.sh`
- Make scripts executable: `chmod +x *.sh`

## Architecture

The project follows a modular shell script architecture:

### Core Scripts

1. **`git_monitor.sh`** - Main monitoring script
   - Scans configured directories for Git repositories (max depth: 2)
   - Checks if local branches are behind their remote counterparts
   - Outputs JSON-formatted status for BetterTouchTool integration
   - Includes timeout handling and graceful error recovery

2. **`show_repos.sh`** - Interactive repository management interface
   - Displays repositories needing updates with specific status
   - Provides menu-driven options to open in Finder/Terminal or pull updates
   - Supports command-line arguments for direct actions
   - Shows macOS notifications when all repos are up-to-date

3. **`list_repos.sh`** - Diagnostic utility
   - Lists all discovered Git repositories and their branch status
   - Useful for debugging configuration issues

4. **`open_in_iterm.scpt`** - AppleScript helper for iTerm2 integration

### Key Functions

The scripts share common functionality:
- `find_git_repos()` - Discovers Git repositories in configured directories
- `check_repo_needs_pull()` - Determines if a repository is behind its remote
- JSON output formatting for BetterTouchTool menu bar display

### Configuration Variables

All scripts share these key configurations:
- `REPOS_ROOT_DIRS` - Array of directories to scan for Git repositories
- `SKIP_FETCH` - Whether to fetch remote updates (default: true for performance)
- `MAX_REPOS` - Maximum number of repositories to check (default: 15)
- `TERMINAL_APP` - Terminal application preference (Terminal or iTerm)

## Common Tasks

### Adding New Repository Directories
Edit the `REPOS_ROOT_DIRS` array in all shell scripts:
```bash
REPOS_ROOT_DIRS=(
  "$HOME/DevProjects"
  "$HOME/NewDirectory"  # Add new directory here
)
```

### Changing Visual Indicators
Modify the icon variables at the top of `git_monitor.sh`:
```bash
ICON_OK="✅"
ICON_NEEDS_PULL="⬇️"
ICON_TIMEOUT="⏱️"
```

### Adjusting Performance Settings
- Change repository scan depth: Modify `-maxdepth` parameter in `find` commands
- Enable remote fetching: Set `SKIP_FETCH=false` (requires SSH key setup)
- Adjust timeout duration: Modify the timeout value in fetch operations

### Testing Changes
1. Run `./git_monitor.sh` to test JSON output formatting
2. Run `./show_repos.sh` to test interactive menu functionality
3. Use `./list_repos.sh` to verify repository discovery

## BetterTouchTool Integration

The script outputs JSON in the format:
```json
{
  "text": "⬇️ 3",
  "color": "255,165,0",
  "font_size": 14
}
```

This integrates with BTT's Shell Script Widget feature to display colored status in the menu bar.
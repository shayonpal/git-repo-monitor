# Git Repository Monitor

Automated git repository monitoring system integrated with BetterTouchTool for macOS menu bar notifications.

[![GitHub](https://img.shields.io/badge/GitHub-shayonpal%2Fgit--repo--monitor-blue)](https://github.com/shayonpal/git-repo-monitor)
[![Status](https://img.shields.io/badge/Status-Active-success)](https://github.com/shayonpal/git-repo-monitor)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey)](https://github.com/shayonpal/git-repo-monitor)

## Overview

This system monitors multiple git repositories and provides visual feedback through the macOS menu bar. When repositories fall behind their remotes or have diverged branches, you get immediate notification and can take action through an interactive menu.

## Components

### Core Scripts

- **`git_monitor.sh`** - Main monitoring script that runs every 30 minutes via BetterTouchTool
- **`open_in_iterm.scpt`** - AppleScript that provides smart iTerm2 integration
- **`interactive_menu.sh`** - Interactive terminal interface for repository management
- **`fix_repos.sh`** - Automated repository update script
- **`git_utils.sh`** - Shared utilities for consistent repository discovery

### Legacy Scripts

Older scripts moved to `legacy-scripts/` directory for reference.

## Workflow

1. **Continuous Monitoring**: BetterTouchTool runs `git_monitor.sh` every 30 minutes
2. **Menu Bar Display**: Shows repository status (✅ all clean, ⬇️ N repos need attention)
3. **Smart Interaction**: Click menu bar icon triggers different actions:
   - **All repos clean**: Shows notification only
   - **Repos need attention**: Opens iTerm2 with interactive menu

## Interactive Menu Options

When repositories need updates, you get these options:

- **`t`** - Open repository in Terminal (iTerm2)
- **`c`** - Open repository in Cursor IDE  
- **`z`** - Open repository in Zed IDE
- **`p`** - Pull updates for a specific repository
- **`a`** - Pull updates for ALL repositories
- **`q`** - Quit

## Repository Detection

The system monitors repositories in:
- `~/DevProjects/`
- `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/LifeOS (iCloud)/`

Handles both:
- **Behind remote**: Repositories that need pulling
- **Diverged branches**: Repositories with conflicting local and remote changes

## Auto-Fix Capabilities

The system can automatically:
- Pull updates for clean repositories
- Handle uncommitted changes with user-provided commit messages
- Use rebase strategy to avoid merge conflicts
- Resolve diverged branches safely

## Setup

### Prerequisites

- macOS
- [BetterTouchTool](https://folivora.ai/)
- [iTerm2](https://iterm2.com/)
- Git repositories with remote tracking
- Cursor IDE (optional)
- Zed IDE (optional)

### BetterTouchTool Configuration

1. Create a new menu bar widget in BetterTouchTool
2. Set script to run: `/Users/shayon/DevProjects/automonitor-git-repos/git_monitor.sh`
3. Set refresh interval to 1800 seconds (30 minutes)
4. Configure display to show JSON output as menu bar text
5. Set click action to run AppleScript: `/Users/shayon/DevProjects/automonitor-git-repos/open_in_iterm.scpt`

## Visual Indicators

The script provides visual feedback in the menu bar:

- **✅** in green: All repositories are up-to-date
- **⬇️ N** in orange: N repositories need attention
- **⏱️** in orange: Timeout occurred while checking

## Files Structure

```
automonitor-git-repos/
├── git_utils.sh           # Shared repository discovery functions
├── git_monitor.sh         # BetterTouchTool monitoring script
├── open_in_iterm.scpt     # Smart AppleScript launcher
├── interactive_menu.sh    # Interactive user interface
├── fix_repos.sh          # Automated repository fixes
├── README.md             # This documentation
└── legacy-scripts/       # Archived old scripts
```

## Features

- **Cross-device workflow**: Works seamlessly when switching between development machines
- **Smart notifications**: Only interrupts when action is needed
- **Multiple IDE support**: Open repositories in iTerm2, Cursor, or Zed
- **Granular control**: Update specific repositories or all at once
- **Diverged branch handling**: Safely resolves conflicting changes
- **Uncommitted changes**: Prompts for commit messages before pulling
- **Consistent logic**: Shared utilities ensure all scripts work identically
- **15-second fetch timeout**: Reliable network operations

## Customization

You can customize the system by modifying `git_utils.sh`:

- `REPOS_ROOT_DIRS`: Directories to search for git repositories
- Fetch timeout duration
- Repository discovery depth

## Troubleshooting

- If no repositories are found, check `REPOS_ROOT_DIRS` in `git_utils.sh`
- Ensure all scripts have executable permissions
- For slow performance, the fetch timeout can be adjusted
- If iTerm2 doesn't open, verify the AppleScript path in BetterTouchTool

## Recent Updates

- **2025-06-06**: Fixed remote change detection by enabling fetch by default (resolved issue #1)
- **2025-06-06**: Enhanced git monitoring system with shared utilities and IDE integration
- **2025-06-06**: Updated AppleScript path to match current directory structure
- **2025-06-02**: Consolidated documentation and improved project structure

## Known Issues

Currently no open issues. The system is stable and actively maintained.

## Contributing

Issues and pull requests are welcome at [GitHub](https://github.com/shayonpal/git-repo-monitor).

## Version History

- **2025-06-06**: Enhanced system with shared utilities, IDE support, and diverged branch handling
- **2025-06-04**: Fixed remote change detection issue
- **Previous**: Basic monitoring with simple pull functionality

## Last Updated

2025-06-24 - Documentation updated to reflect current project status and repository structure.
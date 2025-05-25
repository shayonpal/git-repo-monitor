# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a script for automatically monitoring local Git repositories and comparing them with their remote counterparts. The script is designed to work with BetterTouchTool to display repository status in the macOS menu bar.

## Development Commands

- Test the script: `./git_monitor.sh`

## Architecture

The project has a simple architecture:

1. `git_monitor.sh` - The main shell script that:
   - Locates Git repositories in specified directories
   - Compares local and remote repository states
   - Outputs formatted text for BetterTouchTool's menu bar item

The script uses a modular approach with separate functions for:
- Finding Git repositories
- Checking if repositories need to be pulled
- Formatting output for BetterTouchTool

## Common Tasks

- Modifying search directories: Edit the `REPOS_ROOT_DIRS` array in `git_monitor.sh`
- Changing icons: Modify the icon variables at the top of `git_monitor.sh`
- Adjusting search depth: Modify the `-maxdepth` parameter in the `find` command
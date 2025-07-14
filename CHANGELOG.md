# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2025-07-14

### Changed
- Removed Obsidian vault from monitoring scope in `git_utils.sh`
- Simplified REPOS_ROOT_DIRS configuration to only monitor DevProjects directory
- Reduced unnecessary monitoring overhead for non-development repositories

### Added
- Next Session Instructions.md for session continuity and handoff documentation

## [1.1.1] - 2025-07-14

### Added
- GitHub badges to README for project visibility
- Recent updates section in README documentation
- Contributing section with link to GitHub repository
- This CHANGELOG.md file to track project changes

### Changed
- Updated README.md with current project status and GitHub repository information
- Enhanced documentation structure with better organization
- Updated last modified date to reflect current maintenance

### Fixed
- No fixes in this update

### Removed
- No removals in this update

## [1.1.0] - 2025-06-06

### Added
- Shared utilities module (`git_utils.sh`) for consistent repository discovery
- Support for multiple IDE options (iTerm2, Cursor, Zed)
- Enhanced diverged branch handling with safe resolution
- 15-second fetch timeout for reliable network operations
- Improved error handling and user feedback

### Changed
- Major system overhaul with modular architecture
- Enhanced workflow with better user interaction
- Improved AppleScript integration for smarter iTerm2 handling

### Fixed
- Remote change detection by enabling fetch by default (issue #1)
- AppleScript path to match current directory structure

### Removed
- Legacy scripts moved to `legacy-scripts/` directory

## [1.0.0] - 2025-06-02

### Added
- Initial release of Git Repository Monitor
- BetterTouchTool integration for menu bar notifications
- Basic monitoring with simple pull functionality
- Interactive menu system
- Automatic repository discovery
- Visual status indicators (✅, ⬇️, ⏱️)

### Changed
- Consolidated documentation into organized structure

### Fixed
- Initial bug fixes and stability improvements

### Removed
- Removed redundant scripts and documentation
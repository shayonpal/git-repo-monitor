#!/bin/bash

# Script to debug Git repository status detection

echo "Checking needle-mcp repository status..."
cd "$HOME/DevProjects/needle-mcp" || exit 1
git fetch
echo "Git status output:"
git status -uno
echo ""
echo "Grep command result:"
git status -uno | grep -E 'Your branch is behind|have diverged' && echo "NEEDS PULL: Match found" || echo "UP TO DATE: No match found"
echo ""
echo ""

echo "Checking RSS-Reader-PWA repository status..."
cd "$HOME/DevProjects/RSS-Reader-PWA" || exit 1
git fetch
echo "Git status output:"
git status -uno
echo ""
echo "Grep command result:"
git status -uno | grep -E 'Your branch is behind|have diverged' && echo "NEEDS PULL: Match found" || echo "UP TO DATE: No match found"
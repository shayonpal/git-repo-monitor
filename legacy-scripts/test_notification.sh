#!/bin/bash

echo "Testing notification..."
osascript << 'EOF'
display notification "All repositories are up to date!" with title "Git Repository Monitor"
EOF
echo "Notification command sent"
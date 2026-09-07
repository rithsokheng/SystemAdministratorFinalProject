#!/bin/bash
git add .
read -p "Enter commit message [Update]: " msg
msg="${msg:-Update}"
git commit -m "$msg"
branch=$(git branch --show-current)
git push origin "$branch"

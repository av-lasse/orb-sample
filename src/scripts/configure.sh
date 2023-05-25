#!/bin/bash
# Get auth token
export GITHUB_TOKEN=${!GH_TOKEN}
[ -z "$GITHUB_TOKEN" ] && echo "A GitHub token must be supplied. Check the \"token\" parameter." && exit 1
echo "export GITHUB_TOKEN=\"${GITHUB_TOKEN}\"" >>"$BASH_ENV"

# Authenticate
echo "Authenticating GH CLI"
gh auth setup-git --hostname "$GH_HOSTNAME"

echo "Viewing authentication GH authentication status"
gh auth status || echo "Viewing auth status is unavailable without proper scope."

# Configure
echo "Disabling interactive prompts for GH CLI"
gh config set prompt disabled

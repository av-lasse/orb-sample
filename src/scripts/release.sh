#!/bin/bash
#Check for github credentials
if [ -z "$GITHUB_TOKEN" ]; then
  echo "The GITHUB_TOKEN environment variable is not set."
  exit 1
fi
#Check if we have sudo rights
if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
#check if semver is installed
if ! command -v semver &> /dev/null; then
  echo "Installing semver"
  $SUDO wget -qO- /usr/local/bin/semver https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver
  $SUDO chmod +x /usr/local/bin/semver
fi

#Get the latest PR number and extract the semver from the title
pr_number=$(git log -1 --pretty=%s. | sed 's/^[^0-9]*\([0-9]\+\).*/\1/')
semver_increment=$(gh pr view "$pr_number" --json title | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')
echo "SemVer increment: $semver_increment"

if [ -z "$semver_increment" ]; then
  echo "Commit subject did not indicate which SemVer increment to make."
  echo "To create the tag and release, you can ammend the commit or push another commit with [semver:INCREMENT] in the subject where INCREMENT is major, minor, patch."
  echo "Note: To indicate intention to skip, include [semver:skip] in the commit subject instead."
fi

last_tag=$( gh release view --json tagName --jq '.tagName')
if [ -z "$semver_increment" ]; then
  echo "could not find the last tag"
  exit 1
fi
new_tag=$(semver bump "$semver_increment" "$last_tag")

tag_prefix="v"
echo "Creating Release $tag_prefix$new_tag ."
gh release create "$tag_prefix$new_tag" --generate-notes
echo "Release $tag_prefix$new_tag created."
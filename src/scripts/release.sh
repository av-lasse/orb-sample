#!/bin/bash
#Check for github credentials
if [ -z "$GITHUB_TOKEN" ]; then
  echo "The GITHUB_TOKEN environment variable is not set."
  echo "You must set a GITHUB_TOKEN environment variable."
  exit 1
fi
#check if semver is installed
if ! command -v semver &> /dev/null; then
  echo "Installing semver"
  wget -qO- /usr/local/bin/semver https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver
  chmod +x /usr/local/bin/semver
fi

#Get the PR number and extract the semver from the title
pr_number=$(git log -1 --pretty=%s. | sed 's/^[^0-9]*\([0-9]\+\).*/\1/')
semver_increment=$(gh pr view "$pr_number" --json title | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')
echo "SemVer increment: $semver_increment"

if [ -z "$semver_increment" ]; then
  echo "Commit subject did not indicate which SemVer increment to make."
  echo "To create the tag and release, you can ammend the commit or push another commit with [semver:INCREMENT] in the subject where INCREMENT is major, minor, patch."
  echo "Note: To indicate intention to skip, include [semver:skip] in the commit subject instead."
elif [ "$semver_increment" == "skip" ]; then
  echo "SemVer in commit indicated to skip release."
  exit
fi

last_tag=$(git describe --tags --abbrev=0)
new_tag=$(semver bump "$semver_increment" "$last_tag")

tag_prefix="v"

echo "Creating Release $new_tag ."
gh release create "$tag_prefix$new_tag" --generate-notes
echo "Release $new_tag created."
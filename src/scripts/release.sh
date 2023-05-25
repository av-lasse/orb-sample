#!/bin/bash

#Get the latest PR number and extract the semver from the title
PR_NUMBER=$(gh pr list --state merged --json number --jq '.[0].number' --base main)
SEMVER_INCREMENT=$(gh pr view "$PR_NUMBER" --json title | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')

echo "SemVer increment: $SEMVER_INCREMENT"

if [ -z "$SEMVER_INCREMENT" ]; then
  echo "Commit subject did not indicate which SemVer increment to make."
  echo "To create the tag and release, you can ammend the commit or push another commit with [semver:INCREMENT] in the subject where INCREMENT is major, minor, patch."
  echo "Note: To indicate intention to skip, include [semver:skip] in the commit subject instead."
  exit 1
fi

LAST_TAG=$( gh release view --json tagName --jq '.tagName')
echo "Lastest release $LAST_TAG"
if [ -z "$LAST_TAG" ]; then
  echo "could not find the last tag"
  exit 1
fi

NEW_TAG=$(semver bump "${SEMVER_INCREMENT}" "${LAST_TAG}")
FINAL_TAG="v$NEW_TAG"

echo "Creating Release $FINAL_TAG ."
gh release create "$FINAL_TAG" --generate-notes
echo "Release $FINAL_TAG created."

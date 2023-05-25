#!/bin/bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
SEMVER_INCREMENT="prerelease ${CURRENT_BRANCH}."

LAST_MAIN_TAG=$( gh release view --json tagName --jq '.tagName')
LAST_TAG=$(git tag -l --sort=-version:refname ${LAST_MAIN_TAG}-${CURRENT_BRANCH}* | head -n 1)

echo "Lastest release $LAST_TAG"
if [ -z "$LAST_TAG" ]; then
        echo "could not find the last tag"
        NEW_TAG=$(semver bump ${SEMVER_INCREMENT} ${LAST_MAIN_TAG}-${CURRENT_BRANCH})
else
        NEW_TAG=$(semver bump ${SEMVER_INCREMENT} ${LAST_TAG})
fi

FINAL_TAG="v$NEW_TAG"
git tag $FINAL_TAG
git push origin $FINAL_TAG
echo "Tag $FINAL_TAG created."


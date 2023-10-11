#!/bin/bash

IFS=',' read -ra push_tags <<< "$PUSH_TAGS"
for tag in "${push_tags[@]}"; do
  docker tag "${ECR_REGISTRY}/${SERVICE}:${PULL_TAG}" "${ECR_REGISTRY}/${SERVICE}:${tag}"
done

for tag in "${push_tags[@]}"; do
  docker push "${ECR_REGISTRY}/${SERVICE}:${tag}"
done

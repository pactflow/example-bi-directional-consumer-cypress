#!/bin/bash

# Script to trigger a workflow_dispatch event
# and provide a set of explicit input events
# - PACT_CLI_DOCKER_VERSION
#   - latest
#   - any tag
# - PACT_CLI_VERSION
#   - latest
#   - any tag
# - PACT_CLI_STANDALONE_VERSION
#   - 1.88.90
#   - any version release tag
# Requires a Github API token with repo scope stored in the
# environment variable GITHUB_ACCESS_TOKEN_FOR_PF_RELEASES
# Adapated from Beth Skurrie's excellent script at
# https://github.com/pact-foundation/pact-ruby/blob/master/script/trigger-release.sh
# Reference documentation
# https://docs.github.com/en/rest/actions/workflows#create-a-workflow-dispatch-event

: "${GITHUB_ACCESS_TOKEN_FOR_PF_RELEASES:?Please set environment variable GITHUB_ACCESS_TOKEN_FOR_PF_RELEASES}"

repository_slug=$(git remote get-url $(git remote show) | cut -d':' -f2 | sed 's/\.git//')
# function print_help { echo "Usage" >&2; }

while getopts d:r:s:h: flag; do
    case "${flag}" in
    d) PACT_CLI_DOCKER_VERSION=${OPTARG:-'latest'} ;;
    r) PACT_CLI_VERSION=${OPTARG:-'latest'} ;;
    s) PACT_CLI_STANDALONE_VERSION=${OPTARG:-'1.88.90'} ;;
    \?) echo "Usage: cmd [-d] \$PACT_CLI_DOCKER_VERSION \[-r] \$PACT_CLI_VERSION [-s] \$PACT_CLI_STANDALONE_VERSION" ;;
    esac
done

BRANCH=$(git rev-parse --abbrev-ref HEAD)
output=$(curl -L -v -X POST https://api.github.com/repos/${repository_slug}/actions/workflows/cross_test.yml/dispatches \
    -H 'Accept: application/vnd.github.v3+json' \
    -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN_FOR_PF_RELEASES" \
    -d "{\"ref\":\"$BRANCH\",\"inputs\":{\"PACT_CLI_DOCKER_VERSION\":\"$PACT_CLI_DOCKER_VERSION\",\"PACT_CLI_VERSION\":\"$PACT_CLI_VERSION\",\"PACT_CLI_STANDALONE_VERSION\":\"$PACT_CLI_STANDALONE_VERSION\"}}" 2>&1)

if ! echo "${output}" | grep "HTTP\/2 204" >/dev/null; then
    echo "$output" | sed "s/${GITHUB_ACCESS_TOKEN_FOR_PF_RELEASES}/********/g"
    echo "failed to trigger for $repository_slug using PACT_CLI_DOCKER_VERSION=$PACT_CLI_DOCKER_VERSION / PACT_CLI_VERSION=$PACT_CLI_VERSION / PACT_CLI_STANDALONE_VERSION=$PACT_CLI_STANDALONE_VERSION"
    exit 1
else
    echo "workflow_dispatch triggered for $repository_slug using PACT_CLI_DOCKER_VERSION=$PACT_CLI_DOCKER_VERSION / PACT_CLI_VERSION=$PACT_CLI_VERSION / PACT_CLI_STANDALONE_VERSION=$PACT_CLI_STANDALONE_VERSION"
fi

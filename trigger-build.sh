#!/usr/bin/env bash
set -euo pipefail

# GitHub repository info
OWNER="sky1218"
REPO="pytorch-docker-build"
WORKFLOW_FILE="build-pytorch.yml"

show_help() {
    cat << EOF
Usage: ./trigger-build.sh [OPTIONS] [VERSIONS...]

Trigger GitHub Actions to build multiple PyTorch Docker images in parallel.

OPTIONS:
    -h, --help      Show this help message
    -f, --file      Read versions from a JSON file

VERSION FORMAT:
    TORCH-cudaCUDA-pyPYTHON
    Example: 2.8.0-cuda12.9-py3.11

EXAMPLES:
    # Build single version
    ./trigger-build.sh 2.8.0-cuda12.9-py3.11

    # Build multiple versions (parallel)
    ./trigger-build.sh 2.8.0-cuda12.9-py3.11 2.7.1-cuda12.8-py3.12 2.5.1-cuda12.4-py3.11

    # Build from JSON file
    ./trigger-build.sh -f versions.json

    # Build all default versions
    ./trigger-build.sh

EOF
    exit 0
}

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo "Error: Not logged in to GitHub CLI."
    echo "Run: gh auth login"
    exit 1
fi

# Parse version string like "2.8.0-cuda12.9-py3.11" into JSON
parse_version() {
    local ver="$1"
    # Extract parts using regex
    if [[ "$ver" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-cuda([0-9]+\.[0-9]+)-py([0-9]+\.[0-9]+)$ ]]; then
        echo "{\"torch\":\"${BASH_REMATCH[1]}\",\"cuda\":\"${BASH_REMATCH[2]}\",\"python\":\"${BASH_REMATCH[3]}\"}"
    else
        echo "Error: Invalid version format: $ver" >&2
        echo "Expected format: TORCH-cudaCUDA-pyPYTHON (e.g., 2.8.0-cuda12.9-py3.11)" >&2
        return 1
    fi
}

# Default versions to build
DEFAULT_VERSIONS='[
  {"torch":"2.8.0","cuda":"12.9","python":"3.12"},
  {"torch":"2.8.0","cuda":"12.9","python":"3.11"},
  {"torch":"2.7.1","cuda":"12.8","python":"3.12"},
  {"torch":"2.6.0","cuda":"12.6","python":"3.11"},
  {"torch":"2.5.1","cuda":"12.4","python":"3.11"}
]'

# Parse arguments
VERSIONS=""
USE_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -f|--file)
            USE_FILE="$2"
            shift 2
            ;;
        *)
            # Parse version strings
            if [[ -z "$VERSIONS" ]]; then
                VERSIONS="[$(parse_version "$1")"
            else
                VERSIONS="$VERSIONS,$(parse_version "$1")"
            fi
            shift
            ;;
    esac
done

# Handle file input
if [[ -n "$USE_FILE" ]]; then
    if [[ ! -f "$USE_FILE" ]]; then
        echo "Error: File not found: $USE_FILE"
        exit 1
    fi
    VERSIONS=$(cat "$USE_FILE")
elif [[ -n "$VERSIONS" ]]; then
    VERSIONS="$VERSIONS]"
else
    VERSIONS="$DEFAULT_VERSIONS"
fi

# Compact JSON (remove newlines)
VERSIONS_COMPACT=$(echo "$VERSIONS" | jq -c '.')
VERSION_COUNT=$(echo "$VERSIONS" | jq 'length')

echo "=========================================="
echo "  PyTorch Docker Build Trigger"
echo "=========================================="
echo
echo "Building $VERSION_COUNT image(s) in parallel:"
echo "$VERSIONS" | jq -r '.[] | "  - \(.torch)-cuda\(.cuda)-py\(.python)"'
echo

# Trigger the workflow
gh workflow run "$WORKFLOW_FILE" \
    --repo "$OWNER/$REPO" \
    -f versions="$VERSIONS_COMPACT"

echo "Workflow triggered successfully!"
echo
echo "View progress: https://github.com/$OWNER/$REPO/actions"
echo "Docker Hub:    https://hub.docker.com/r/sky1218/pytorch/tags"

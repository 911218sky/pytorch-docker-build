#!/usr/bin/env bash
set -euo pipefail

# GitHub repository info
OWNER="911218sky"
REPO="pytorch-docker-build"
WORKFLOW_FILE="build-jetson.yml"

show_help() {
    cat << EOF
Usage: ./trigger-build-jetson.sh [OPTIONS] [VERSIONS...]

Trigger GitHub Actions to build Jetson PyTorch Docker images in parallel.

OPTIONS:
    -h, --help      Show this help message
    -f, --file      Read versions from a JSON file

VERSION FORMAT:
    TORCH-jpJETPACK-pyPYTHON
    Example: 2.9.0-jp6.0-py3.11

EXAMPLES:
    # Build single version
    ./trigger-build-jetson.sh 2.9.0-jp6.0-py3.11

    # Build multiple versions (parallel)
    ./trigger-build-jetson.sh 2.9.0-jp6.0-py3.11 2.8.0-jp6.0-py3.12

    # Build from JSON file
    ./trigger-build-jetson.sh -f versions-jetson.jsonc

    # Build all default versions
    ./trigger-build-jetson.sh

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

# Map JetPack version to L4T version
get_l4t_version() {
    local jp="$1"
    case "$jp" in
        "6.0") echo "r36.2.0" ;;
        "6.1") echo "r36.4.0" ;;
        *) echo "r36.2.0" ;;  # Default to 6.0
    esac
}

# Parse version string like "2.9.0-jp6.0-py3.11" into JSON for Jetson
parse_version() {
    local ver="$1"
    # Extract parts using regex
    if [[ "$ver" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-jp([0-9]+\.[0-9]+)-py([0-9]+\.[0-9]+)$ ]]; then
        local torch="${BASH_REMATCH[1]}"
        local jetpack="${BASH_REMATCH[2]}"
        local python="${BASH_REMATCH[3]}"
        local l4t=$(get_l4t_version "$jetpack")
        echo "{\"l4t\":\"$l4t\",\"jetpack\":\"$jetpack\",\"torch\":\"$torch\",\"python\":\"$python\"}"
    else
        echo "Error: Invalid version format: $ver" >&2
        echo "Expected format: TORCH-jpJETPACK-pyPYTHON (e.g., 2.9.0-jp6.0-py3.11)" >&2
        return 1
    fi
}

# Default versions to build (Jetson - JetPack 6.x only)
DEFAULT_VERSIONS='[
  {"l4t":"r36.2.0","jetpack":"6.0","torch":"2.7.1","python":"3.11"},
  {"l4t":"r36.2.0","jetpack":"6.0","torch":"2.7.1","python":"3.12"},
  {"l4t":"r36.2.0","jetpack":"6.0","torch":"2.8.0","python":"3.11"},
  {"l4t":"r36.2.0","jetpack":"6.0","torch":"2.8.0","python":"3.12"},
  {"l4t":"r36.2.0","jetpack":"6.0","torch":"2.9.0","python":"3.11"},
  {"l4t":"r36.2.0","jetpack":"6.0","torch":"2.9.0","python":"3.12"}
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
    # Remove comments from JSONC file
    VERSIONS=$(grep -v '^\s*//' "$USE_FILE" | jq -c '.')
elif [[ -n "$VERSIONS" ]]; then
    VERSIONS="$VERSIONS]"
else
    VERSIONS="$DEFAULT_VERSIONS"
fi

# Compact JSON (remove newlines)
VERSIONS_COMPACT=$(echo "$VERSIONS" | jq -c '.')
VERSION_COUNT=$(echo "$VERSIONS" | jq 'length')

echo "==========================================="
echo "  Jetson PyTorch Docker Build Trigger"
echo "  (JetPack 6.0 / L4T R36.2.0 / ARM64)"
echo "==========================================="
echo
echo "Building $VERSION_COUNT Jetson image(s) in parallel:"
echo "$VERSIONS" | jq -r '.[] | "  - PyTorch \(.torch)-jp\(.jetpack)-py\(.python)"'
echo
echo "Note: Jetson builds use ARM64 emulation (QEMU) and may take longer."
echo

# Trigger the workflow
gh workflow run "$WORKFLOW_FILE" \
    --repo "$OWNER/$REPO" \
    -f versions="$VERSIONS_COMPACT"

echo "Workflow triggered successfully!"
echo
echo "View progress: https://github.com/$OWNER/$REPO/actions"
echo "Docker Hub:    https://hub.docker.com/r/sky1218/pytorch-jetson/tags"

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_NAME="$(basename "$0")"
LOG_LEVEL="INFO"

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Disable color if not writing to terminal
if [[ ! -t 1 ]]; then
    RED=''; YELLOW=''; GREEN=''; BLUE=''; NC=''
fi

log() {
    local level="$1"
    shift
    local color=""
    case "$level" in
        INFO)  color="$GREEN" ;;
        WARN)  color="$YELLOW" ;;
        ERROR) color="$RED" ;;
        DEBUG) color="$BLUE" ;;
        *)     color="$NC" ;;
    esac
    if [[ "$level" == "DEBUG" && "$LOG_LEVEL" != "DEBUG" ]]; then
        return
    fi
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] [$level] $*${NC}" >&2
}

die() {
    log "ERROR" "$*"
    exit 1
}
trap 'die "An error occurred on line $LINENO."' ERR

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log "ERROR" "Script exited with code $exit_code"
    fi
    log "INFO" "Cleaning up temporary resources..."
}
trap cleanup EXIT

on_sigint() {
    log "WARN" "Interrupted by user (SIGINT)"
    exit 130
}
trap on_sigint SIGINT

on_sigterm() {
    log "WARN" "Terminated (SIGTERM)"
    exit 143
}
trap on_sigterm SIGTERM

#######################################
# Usage
#######################################
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [-f <file>] [-v]

Options:
  -f <file>   Path to input file (required)
  -v          Enable verbose output
  -h          Show help

Example:
  $SCRIPT_NAME -f input.txt -v
EOF
    exit 0
}

#######################################
# Argument parsing
#######################################
FILE=""
VERBOSE=0

while getopts ":f:vh" opt; do
    case "$opt" in
        f) FILE="$OPTARG" ;;
        v) VERBOSE=1 ;;
        h) usage ;;
        :) die "Option -$OPTARG requires an argument." ;;
        \?) die "Invalid option: -$OPTARG" ;;
    esac
done
shift $((OPTIND - 1))

#######################################
# Main
#######################################
main() {
    if [[ -z "$FILE" ]]; then
        die "Missing required argument: -f <file>"
    fi

    if [[ ! -f "$FILE" ]]; then
        die "File not found: $FILE"
    fi

    if [[ "$VERBOSE" -eq 1 ]]; then
        LOG_LEVEL="DEBUG"
        log DEBUG "Verbose mode enabled"
    fi

    log INFO "Processing file: $FILE"



    sleep 1
    log INFO "Success."
}

main "$@"

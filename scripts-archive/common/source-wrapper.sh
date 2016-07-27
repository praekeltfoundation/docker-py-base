#!/bin/sh -e

# Source environment variables from a file at container runtime and then exec a
# command. Useful for adding environment variables at runtime without running a
# shell as the parent container process.
# Usage: source-wrapper.sh [source-file] [exec-command]

. $1; shift

exec "$@"

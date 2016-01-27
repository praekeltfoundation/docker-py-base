#!/bin/bash -e
set -x

# Remove packages and their configuration files.
# Usage: apt-get-purge.sh [packages...]

apt-get purge -qy --auto-remove "$@"

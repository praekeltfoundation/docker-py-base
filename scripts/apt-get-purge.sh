#!/usr/bin/env bash
set -xe

# Remove packages and their configuration files.
# Usage: apt-get-purge.sh [packages...]

apt-get purge -y --auto-remove "$@"

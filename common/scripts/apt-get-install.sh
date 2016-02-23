#!/bin/bash -e
set -x

# Install packages using apt-get without leaving a mess behind. Fetches and then
# later removes package indexes and install files.
# Usage: apt-get-install.sh [package...]

# Fetch the package indexes
apt-get update

# Do the install
apt-get install -qy \
  -o APT::Install-Recommends=false \
  -o APT::Install-Suggests=false \
  "$@"

# Clean downloaded package files
apt-get clean

# Remove the package indexes
rm -rf /var/lib/apt/lists/*

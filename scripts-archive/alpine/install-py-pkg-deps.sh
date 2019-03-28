#!/usr/bin/env sh
set -e

# Detects and installs the runtime dependencies of Python packages by
# recursively scanning files in a directory and checking which libraries any
# shared objects are linked against.
#
# Usage: ./install-py-pkg-deps.sh [PKG_DIRS...]
#   PKG_DIRS should be paths to where the Python packages are located, for
#   example, the path to the virtualenv. If not provided, the site-packages
#   directories will be detected and used instead.

PKG_DIRS="$@"

site_packages() {
  python <<EOM
import site
for dir in site.getsitepackages():
  print(dir)
EOM
}

if [ -z "$PKG_DIRS" ]; then
  PKG_DIRS="$(site_packages)"
fi

find_not_installed_libs() {
  # Find all the linked libraries in the provided directories. Parse them into
  # a nice format, sort the unique ones, and remove libpython so that we don't
  # install 2 Pythons.
  local dep_libs="$(scanelf --needed --nobanner --recursive "$@" | \
    awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | \
    sort -u | \
    grep -v 'libpython')"

  # Check whether each library is already installed or not.
  local dep_lib
  for dep_lib in $dep_libs; do
    if ! apk info --installed "$dep_lib" &> /dev/null; then
      echo "$dep_lib"
    fi
  done
}

# Find all the libraries in the directories
DEP_LIBS="$(find_not_installed_libs $PKG_DIRS)"

echo "Found $(echo "$DEP_LIBS" | wc -w) libraries that are not installed: \
$(echo "$DEP_LIBS" | tr "\n" " ")"
if [ -z "$DEP_LIBS" ]; then
  echo "Nothing to do..."
  exit 0
fi

# Use apk to find the packages for the libraries
echo "Searching for packages..."
# Fetch the package index - we need it twice: first for search then for add
apk update
DEP_PKGS="$(apk -q search $DEP_LIBS)"
echo "Found $(echo "$DEP_PKGS" | wc -w) packages to install: \
$(echo "$DEP_PKGS" | tr "\n" " ")"

# Finally, install the packages
apk add $DEP_PKGS

# Clean up the apk index
rm -rf /var/cache/apk/*

# Double check that everything is installed
DEP_LIBS="$(find_not_installed_libs $PKG_DIRS)"
if [ -n "$DEP_LIBS" ]; then
  echo "Unable to install packages for $(echo "$DEP_LIBS" | wc -w) libraries: \
  $(echo "$DEP_LIBS" | tr "\n" " ")"
  exit 1
fi

echo "All dependencies installed :-)"

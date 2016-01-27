#!/bin/bash -e

# This script creates a new user and group based on the UID/GID of the owner of
# a mounted volume in a container.

USAGE="Usage: $0 <volume-path> <user> <group>"
if [ ! "$#" -eq "3" ]; then
    echo "$USAGE"
    exit 1
fi

read VOL_UID VOL_GID <<< $(stat -c '%u %g' $1)
echo "Detected UID $VOL_UID and GID $VOL_GID for volume path $1"

EXISTING_GROUP="$(getent group $VOL_GID | cut -d: -f1)"
if [[ -z $EXISTING_GROUP ]]; then
    groupadd --gid=$VOL_GID "$3"
    echo "Created group '$3' with GID $VOL_GID"
    GROUP_NAME="$3"
else
    echo "Existing group '$EXISTING_GROUP' found for GID $VOL_GID"
    GROUP_NAME=$EXISTING_GROUP
fi

# Create the user with a home directory as npm fails if it can't create ~/.npm
useradd -m --uid=$VOL_UID --gid=$VOL_GID "$2"
echo "Created user '$2' ($VOL_UID) in group '$GROUP_NAME' ($VOL_GID)"

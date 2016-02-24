#!/bin/bash
# The "default parameters to entrypoint" and "exec" forms of Docker's CMD
# instruction don't run in a shell and therefore variables (e.g. $HOME) are not
# evaluated. This script evaluates the CMD values in a shell and then replaces
# the shell process with the evaluated command.
for ORIG in "$@"; do
    PARAM=$(eval "echo ${ORIG}")
    PARAMS+=("${PARAM}")
done

exec "${PARAMS[@]}"

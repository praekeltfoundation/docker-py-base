#!/bin/sh -e

# The "default parameters to entrypoint" and "exec" forms of Docker's CMD
# instruction don't run in a shell and therefore variables (e.g. $HOME) are not
# evaluated. This script evaluates the CMD values in a shell and then replaces
# the shell process with the evaluated command.

for i in $(seq 1 $#); do
  eval "ARG$i=\$(eval echo \$$i)"
  ARGS="${ARGS:+$ARGS }\"\$ARG$i\""
done

eval "set -- $ARGS"
exec "$@"

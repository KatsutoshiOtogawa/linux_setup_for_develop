#!/bin/env bash
#
# explain for command.

#######################################
# write stdout syntax. google style(https://google.github.io/styleguide/shellguide.html)
# Globals:
#   ENV_VARIABLE
# Arguments:
#   All.
# Outputs:
#   format 
# Returns:
#   0 if thing explain situation, non-zero on error.
# Example:
#    "Unable to do_something"  # => you use use sed
#######################################
function command_name() {
}

function usage() {
    cat 1>&2 <<EOF
command_name
show explain command describe

USAGE:
    command_name [FLAGS] [OPTIONS]

FLAGS:
    -h, --help              Prints help information

OPTIONS:
    --debug                 Set bash debug Option
EOF
}

function main {

  local i
  local new_array=( $@ )
  for ((i=0;i<$#;i++)); do
    if [ "${new_array[$i]}" = "--help" ] || [ "${new_array[$i]}" = "-h" ]; then
      usage
      return
    fi
    # if find --debug flag from args, start debug mode.
    if [ "${new_array[$i]}" = "--debug" ]; then
      set -x
      trap "
        set +x
        trap - RETURN
      " RETURN
      unset new_array[$i]
    fi
  done
  # reindex assign.
  new_array=${new_array[@]}

  command_name $new_array
}

main $@


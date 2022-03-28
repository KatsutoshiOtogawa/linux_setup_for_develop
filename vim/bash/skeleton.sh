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
    --dryrun                dry run. check sync process.

OPTIONS:
    --debug                 Set bash debug Option
    --district              If you error occured and not catched, forcfully return. this flag use debug.
    --check-grammer         check bash grammer
    --time                  calculate execute time
EOF
}

function main {

  local i
  local timef=1
  local new_array=( $@ )
  for ((i=0;i<$#;i++)); do
    if [ "${new_array[$i]}" = "--help" ] || [ "${new_array[$i]}" = "-h" ]; then
      usage
      return
    fi
    if [ "${new_array[$i]}" = "--check-grammer" ]; then
      bash -n $(dirname $0)/${BASH_SOURCE[0]}
      return
    fi
    # set time flag for calculate script time.
    if [ "${new_array[$i]}" = "--time" ]; then
      timef=0
      unset new_array[$i]
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

  if [ "$timef" -eq "0" ]; then
    time command_name $new_array
  else
    command_name $new_array
  fi
}

main $@


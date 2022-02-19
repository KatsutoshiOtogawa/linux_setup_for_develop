#!/bin/bash
#
# utils, often use.

function vagrant_provision {
  vagrant ssh -c "
    cd /vagrant_data
    ./invoke.sh
  "
}

function vagrant_init {
  vagrant up --provider virtualbox
  vagrant_save init
  vagrant_provision
}

function vagrant_save {

  local name=$1
  # --prefixなども考える
  if [ -z $name ]; then
    # local format="${prefix} %Y-%m-%dT%H:%M:%S"
    local format="%Y%m%dT%H%M%S"
    name=$(date +"${format}")
  fi

  vagrant snapshot save $name
}

function vagrant_reload {

  vagrant_save
  vagrant reload
}

function vagrant_halt {

  vagrant_save
  vagrant halt
}

function vagrant_up {
  vagrant up
}

function vagrant_is_rhel {

  abc=$(vagrant ssh -c "
    if ls /etc | grep redhat-release > /dev/null && ! ls /etc | grep oracle-release > /dev/null; then
      echo aaa
    fi
  ")
}
function vagrant_subscription_destroy {
  vagrant ssh -c "
    sudo subscription-manager remove --all
    sudo subscription-manager unregister
  "
}

function vagrant_destroy {
  vagrant_subscription_destroy
  vagrant destroy
}

function vagrant_package {
  # defrag
  vagrant ssh -c "
    sudo dd if=/dev/zero of=/EMPTY bs=1M
    sudo rm -f /EMPTY
  "
  vagrant package
}

function usage() {
    cat 1>&2 <<EOF
manage_vagrant
output search engine setting

USAGE:
    manage_vagrant [FLAGS] [OPTIONS]

FLAGS:
    init
    save
    up
    halt
    destroy
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
  vagrant_${new_array[0]}
}

main $@

#!/bin/bash
#
# gnu command util.

#######################################
# output os_type
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   os_type
# Returns:
#   0 if specialize os, non-zero unknown os.
# Example:
#   os_type # => if you use debian systems except ubuntu, output debian
#   os_type # => if you use ubuntu, output ubuntu
#   os_type # => if you use fedora, output fedora
#######################################
function os_type {
    for arg in "$@"; do
    case "$arg" in
      -h|--help)
        function usage() {
          cat 1>&2 << END
os_type
output search engine setting
USAGE:
    gnu_alias [FLAGS] [OPTIONS]
FLAGS:
    -h, --help              Prints help information
OPTIONS:
    --debug                 Set bash debug Option
END
          unset -f usage
        }
        usage
        return
        ;;
      --debug)
        # set debug
        set -x
        trap "
          set +x
          trap - RETURN
        " RETURN
        ;;
      *)
        ;;
    esac
  done

  local os_type

  if ls /etc | grep fedora-release > /dev/null; then
    os_type=fedora
  elif ls /etc | grep redhat-release > /dev/null; then
    os_type=rhel
    # debian systems except ubuntu.
  elif ls /etc | grep debian_version > /dev/null; then
    os_type=debian
  elif ls /etc | grep lsb-release > /dev/null; then
    os_type=ubuntu
  elif ls /etc | grep SuSE-release > /dev/null; then
    os_type=SuSE
    # if you use BSD,
  elif uname | grep -e Darwin -e BSD > /dev/null; then
    os_type=$(uname | grep -e Darwin -e BSD)
  fi

  if [ -z $os_type ]; then
    echo "unknown os" >&2
    return 1
  fi

  echo $os_type
}


function setup {

  # vscodevim.vim
  # editorconfig.editorconfig
  # ms-python.python

  # code --install-extension

  local os=$(os_type)

  if [ "${os}" -eq "fedora" ] || [ "${os}" -eq "rhel" ]; then
      dnf install -y git
  fi

  # install github cli command
  if [ "${os}" -eq "debian" ] || [ "${os}" -eq "ubuntu" ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
  elif [ "${os}" -eq "fedora" ] || [ "${os}" -eq "rhel" ]; then
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install gh
  elif [ "${os}" -eq "SuSE" ]; then
    sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo zypper ref
    sudo zypper install gh
  fi

  # install Anaconda don't need root priveledge.
  curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh
  chmod u+x Anaconda3*
  ./Anaconda3*

}

setup $@

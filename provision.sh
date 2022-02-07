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

function install_GitHubCli {

  local os=$(os_type)

  # install github cli command
  if ! which gh > /dev/null/; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install -y gh
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo dnf install gh
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo zypper ref
      sudo zypper install gh
    fi
  fi

  # github cli setting
  gh config set editor vim
}

function install_Anaconda {
  # install Anaconda don't need root priveledge.
  curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh
  chmod u+x Anaconda3*
  ./Anaconda3*
  rm ./Anaconda3*
}

function install_vscode {

  local file_path=$(dirname $0)
  local os=$(os_type)
  if ! which code > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -P .cache
      .cache/code*.deb
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -P .cache
      .cache/code*.deb
    elif [ "${os}" == "SuSE" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -P .cache
      .cache/code*.deb
    fi
  fi

  # install vscode extension

  eval "$(
    cat ${file_path}/vscode_extension.txt | \
    xargs -I {} echo code --install-extension {};
  )"
}

function install_powershell {

  local os=$(os_type)
  if ! which pwsh > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts_7.2.1-1.deb_amd64.deb \
        && apt install -y ./powershell-lts_7.2* \
        && rm ./powershell-lts_7.2
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm \
        && apt install -y ./powershell-lts_7.2* \
        && rm ./powershell-lts_7.2
    elif [ "${os}" == "SuSE" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm \
        && apt install -y ./powershell-lts_7.2* \
        && rm ./powershell-lts_7.2
    fi
  fi

}

function install_docker {
  local os=$(os_type)
  if ! which docker > /dev/null; then
    if [ "${os}" == "debian" ]; then
      sudo apt-get update
      sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

      curl -fsSL https://download.docker.com/linux/debian/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    elif [ "${os}" == "ubuntu" ]; then
      sudo apt-get update
      sudo apt-get install -y \
          ca-certificates \
          curl \
          gnupg \
          lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    elif [ "${os}" == "fedora" ]; then
      : pass
    elif [ "${os}" == "rhel" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -P .cache
      .cache/code*.deb
    fi
  fi
}


function install_oracle {

  local os=$(os_type)
  if ! which pwsh > /dev/null; then
    if [ "${os}" == "fedora" ]; then
      ./oracle/fedora/setup.sh
    elif [ "${os}" == "rhel" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm \
        && apt install -y ./powershell-lts_7.2* \
        && rm ./powershell-lts_7.2
    fi
  fi

}

function load_env {

  local file_path=$(dirname $0)
  eval "$(
    cat ${file_path}/.env | \
    sed 's/# .*$//' | \
    xargs -I {} echo export {};
  )"
}

function install_essential {

  local os=$(os_type)
  if ! which git > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y git
    elif [ "${os}" == "fedora" ]; then
      sudo dnf install -y git-all
    elif [ "${os}" == "rhel" ]; then
      mkdir .cache
      wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
      tar zxvf git-2* -C .cache
      subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
      dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install git
    fi
  fi

  if ! which vim > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y vim
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      sudo dnf install -y vim
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vim
    fi
  fi

  if ! which locate > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y mlocate
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      sudo dnf install -y mlocate
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install mlocate
    fi
  fi

  # environment variable display dont use,
  if ! which xclip > /dev/null && [ -z "${DISPLAY}" ] ; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y xclip
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      sudo dnf install -y xclipboard
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install xclipboard
    fi
  fi

  # install pwmake, pwmake generate password following os security policy.
  if ! which mlocate > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y libpwquality-tools
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      sudo dnf install -y libpwquality
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install libpwquality
    fi
  fi

}

function register_subscription {

  local os=$(os_type)

  if [ "${os}" == "rhel" ]; then
    # register system
    # and register auto subscription
    subscription-manager register \
      --username $REGISTER_SUBSCRIPTION_USERNAME \
      --password $REGISTER_SUBSCRIPTION_PASSWORD \
      --autosubscribe
  fi

}

function setup {

  # load
  load_env

  register_subscription

  install_essential

# INSTALL_POSTGRES=
# INSTALL_MARIADB=
  mkdir .cache
  if [ "${INSTALL_GITHUBCLI}" == "yes" ]; then
    install_GitHubCli
  fi

  if [ "${INSTALL_ANACONDA}" == "yes" ]; then
    install_Anaconda
  fi
  if [ "${INSTALL_VSCODE}" == "yes" ]; then
    install_vscode
  fi
  if [ "${INSTALL_DOCKER}" == "yes" ]; then
    install_docker
  fi

  if [ "${INSTALL_POWERSHELL}" == "yes" ]; then
    install_powershell
  fi
  if [ "${INSTALL_ORACLE}" == "yes" ]; then
    install_oracle
  fi

}

setup $@

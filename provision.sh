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
    # oracle linux has redhat-relese, except oracle.
  elif ls /etc | grep redhat-release > /dev/null && ! ls /etc | grep oracle-release > /dev/null; then
    os_type=rhel
  elif ls /etc | grep oracle-release > /dev/null; then
    os_type=oracle
  elif ls /etc | grep centos-release > /dev/null; then
    os_type=centos
  elif cat /etc/os-release | grep "Amazon Linux 2" > /dev/null; then
    os_type=amazonlinux2
    # debian systems except ubuntu.
  elif ls /etc | grep debian_version > /dev/null; then
    os_type=debian
  elif ls /etc | grep lsb-release > /dev/null; then
    os_type=ubuntu
  elif ls /etc | grep SuSE-release > /dev/null; then
    os_type=SuSE
  elif ls /etc | grep arch-release > /dev/null; then
    os_type=arch
  elif ls /etc | grep gentoo-release > /dev/null; then
    os_type=gentoo
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
  if ! command -v gh > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install -y gh
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo dnf install -y gh
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo yum install -y gh
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo zypper -y ref
      sudo zypper -y install gh
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
  if ! command -v code > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -P .cache
      .cache/code*.deb
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
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
    xargs -I {} code --install-extension {};
  )"
}

function install_powershell {

  local os=$(os_type)
  if ! command -v pwsh > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts_7.2.1-1.deb_amd64.deb \
        && apt install -y ./powershell-lts_7.2* \
        && rm ./powershell-lts_7.2
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm \
        && dnf install -y ./powershell-lts_7.2* \
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
  if ! command -v docker > /dev/null; then
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


function install_oracle_18c {

  local file_path=$(dirname $0)
  local os=$(os_type)
  # 帰る
  if ! command -v pwsh > /dev/null; then
    if [ "${os}" == "fedora" ]; then
      sudo $file_path/oracle-18c/fedora/setup.sh
    elif [ "${os}" == "rhel" ]; then
      sudo $file_path/oracle-18c/rhel/setup.sh
    elif [ "${os}" == "oracle" ]; then
      sudo $file_path/oracle-18c/oraclelinux/setup.sh
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo $file_path/oracle-18c/amazonlinux2/setup.sh
    fi
  fi

}

function install_oracle_21c {

  local file_path=$(dirname $0)
  local os=$(os_type)
  if ! command -v pwsh > /dev/null; then
    if [ "${os}" == "fedora" ]; then
      sudo $file_path/oracle-21c/fedora/setup.sh
    elif [ "${os}" == "rhel" ]; then
      sudo $file_path/oracle-21c/rhel/setup.sh
    elif [ "${os}" == "oracle" ]; then
      sudo $file_path/oracle-21c/oraclelinux/setup.sh
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo $file_path/oracle-21c/amazonlinux2/setup.sh
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
  if ! command -v git > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y git
    elif [ "${os}" == "fedora" ]; then
      sudo dnf install -y git-all
    elif [ "${os}" == "rhel" ]; then
      sudo subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
      sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
      sudo dnf install -y git
    elif [ "${os}" == "oracle" ]; then
      sudo dnf install -y git
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y git
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install git
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add git
    fi
  fi

  if ! command -v curl > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y curl
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y curl
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install curl
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add curl
    fi
  fi

  if ! command -v vim > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y vim
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y vim
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vim
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add vim
    fi
  fi

  if ! command -v locate > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y mlocate
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y mlocate
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install mlocate
    fi
  fi

  # environment variable display dont use,
  if ! command -v xclip > /dev/null && [ -z "${DISPLAY}" ] ; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y xclip
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y xclip
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo amazon-linux-extras install epel -y
      sudo yum install -y xclip
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install xclipboard
    fi
  fi

  # install pwmake, pwmake generate password following os security policy.
  if ! command -v pwmake > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y libpwquality-tools
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y libpwquality
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y libpwquality
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install libpwquality
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add libpwquality
    fi
  fi

}

function install_offensive_security {

  local os=$(os_type)
  if ! command -v nmap > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y nmap
    elif [ "${os}" == "fedora" ]; then
      sudo dnf install -y nmap
    elif [ "${os}" == "rhel" ]; then
      sudo dnf install -y nmap
    elif [ "${os}" == "oracle" ]; then
      sudo dnf install -y nmap
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y nmap
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install nmap
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add git
    fi
  fi

  if ! command -v netdiscover > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y netdiscover
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y netdiscover
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install netdiscover
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add netdiscover
    fi
  fi

  if ! command -v dirb > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y dirb
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y dirb
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install dirb
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add dirb
    fi
  fi

  if ! command -v wireshark > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y wireshark
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y wireshark
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install wireshark
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add wireshark
    fi
  fi

  if ! command -v nbtscan > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y nbtscan
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y nbtscan
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install nbtscan
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add nbtscan
    fi
  fi


# wget https://archive.kali.org/archive-key.asc
# gpg --no-default-keyring --keyring /etc/apt/trusted.gpg.d/kali-repository.gpg --import ./archive-key.asc
# armitage
# openvas
# unicornscan

  if ! command -v vim > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y vim
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y vim
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vim
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add vim
    fi
  fi

  if ! command -v locate > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y mlocate
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y mlocate
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install mlocate
    fi
  fi

  # environment variable display dont use,
  if ! command -v xclip > /dev/null && [ -z "${DISPLAY}" ] ; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y xclip
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y xclip
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo amazon-linux-extras install epel -y
      sudo yum install -y xclip
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install xclipboard
    fi
  fi

  # install pwmake, pwmake generate password following os security policy.
  if ! command -v pwmake > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y libpwquality-tools
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
      sudo dnf install -y libpwquality
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y libpwquality
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install libpwquality
    fi
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add libpwquality
    fi
  fi

}

function register_subscription {

  local os=$(os_type)

  if [ "${os}" == "rhel" ]; then
    # register system
    # and register auto subscription
    sudo subscription-manager register \
      --username $REGISTER_SUBSCRIPTION_USERNAME \
      --password $REGISTER_SUBSCRIPTION_PASSWORD \
      --autosubscribe
  fi

}

function set_locale {

  local os=$(os_type)

  echo export LANG=en_US.UTF-8 >> $HOME/.bashrc

  if [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
    # fix language pack missing. this is a rhel8 and centos8 bug. (https://unixcop.com/fix-problem-failed-to-set-locale-defaulting-to-c-utf-8-in-centos-8-rhel-8/)
    sudo dnf install -y glibc-all-langpacks langpacks-en

    # if grep LC_ALL= $HOME/.bash_profile > /dev/null; then
    #   echo export LC_ALL=C >> $HOME/.bashrc
    # fi
    # if sudo grep LC_ALL= /root/.bash_profile > /dev/null; then
    #   sudo echo export LC_ALL=C >> /root/.bashrc
    # fi
  fi

}

function set_package_mirror {

  if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
    : pass
  elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ]; then
    : pass
  elif [ "${os}" == "amazonlinux2" ]; then
    : pass
  elif [ "${os}" == "SuSE" ]; then
    : pass
  elif [ "${os}" == "gentoo" ]; then
    : pass
    # $FreeBSD$
#
# To disable this repository, instead of modifying or removing this file,
# create a /usr/local/etc/pkg/repos/FreeBSD.conf file:
#
#   mkdir -p /usr/local/etc/pkg/repos
#   echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
#

# FreeBSD: {
#   url: "pkg+http://pkg.FreeBSD.org/${ABI}/quarterly",
#   mirror_type: "srv",
#   signature_type: "fingerprints",
#   fingerprints: "/usr/share/keys/pkg",
#   enabled: yes
# }
  elif [ "${os}" == "OpenBSD" ]; then
    # prior japan mirror to usa.
    sed -i '1ihttps://ftp.riken.jp/pub/OpenBSD' /etc/installurl
    # export PKG_PATH="ftp://ftp.iij.ad.jp/pub/OpenBSD/$(uname -r)/packages/$(uname -m)"
  fi
}

function install_system_backup_and_snapshot {
  if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
    # update package list
    sudo apt update
    # snapshotを撮ってsystemをいつでも戻せるようにする。
    sudo apt -y install timeshift
  elif [ "${os}" == "gentoo" ]; then
    : pass
  elif [ "${os}" == "FreeBSD" ]; then
    sudo freebsd-update fetch
  elif [ "${os}" == "OpenBSD" ]; then
    sudo syspatch
  fi
}

function install_security_update {
  if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
    # update package list
    sudo apt update
    # snapshotを撮ってsystemをいつでも戻せるようにする。
    sudo unattended-upgrade --dry-run
    # ok かどうか聞いてからupdate
    sudo unattended-upgrade
  elif [ "${os}" == "gentoo" ]; then
    : pass
  elif [ "${os}" == "FreeBSD" ]; then
    sudo freebsd-update fetch
  elif [ "${os}" == "OpenBSD" ]; then
    sudo syspatch
  fi
}

function install_desktop {
  if [ "${os}" == "gentoo" ]; then
    : pass
  elif [ "${os}" == "FreeBSD" ]; then
    : pass
  elif [ "${os}" == "OpenBSD" ]; then
    # export PKG_PATH="ftp://ftp.iij.ad.jp/pub/OpenBSD/$(uname -r)/packages/$(uname -m)"
    # can't install openbsd6.9 or openbsd 7.0
    # sudo pkg_add xfce xfce-extras consolekit2 scim-anthy
    # pkg_add mixfont-mplus-ipa-20060520p7 mplus-fonts-063a
  fi
}

function install_font_language {
  if [ "${os}" == "gentoo" ]; then
    : pass
  elif [ "${os}" == "FreeBSD" ]; then
    : pass
  elif [ "${os}" == "OpenBSD" ]; then
    # sudo pkg_add mixfont-mplus-ipa-20060520p7 mplus-fonts-063a
  fi
}

function setup {
  # export PKG_PATH="ftp://ftp.iij.ad.jp/pub/OpenBSD/$(uname -r)/packages/$(uname -m)"
  # export PKG_CACHE="$HOME/Downloads/OpenBSD/$(uname -r)-$(uname -m)-packages/"
  # load
  load_env

  set_locale

  register_subscription

  install_essential

  # if doesnot exists directory, create.
  if [ ! -d .cache ]; then
    mkdir .cache
  fi

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

  if [ "${INSTALL_ORACLE_18C}" == "yes" ] || [ "${INSTALL_ORACLE_21C}" == "yes" ]; then
    if [ "${INSTALL_ORACLE_18C}" == "yes" ] && [ "${INSTALL_ORACLE_21C}" == "yes" ]; then

      echo "select oracle18c or oracle21c" >&2
      return 1
    elif [ "${INSTALL_ORACLE_18C}" == "yes" ]; then
      install_oracle_18c
    elif [ "${INSTALL_ORACLE_21C}" == "yes" ]; then
      install_oracle_21c
    fi
  fi

}

setup $@

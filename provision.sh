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
    cat vscode_extension.txt | \
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
    elif [ "${os}" == "rhel" ]; then
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

      # compat-libcap1,compat-libstdc++-33 required oracle database.
      # these library needs fedora only.rhel,oracle linux are alredy installed.
      dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libcap1-1.10-7.el7.x86_64.rpm
      dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
      dnf -y install libnsl

      # pre install packages.these packages are required expcept for oraclelinux.
      curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm -L https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
      dnf -y install oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
      rm oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

      # silent install oracle database.
      mkdir /xe_logs

      # set password not to contain symbol. oracle password can't be used symbol.
      ORACLE_PASSWORD=`pwmake 128 | sed 's/\W//g'`

      curl -o oracle-database-xe-18c-1.0-1.x86_64.rpm -L https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm
      echo finish downloading oracle database!
      echo installing oracle database...
      dnf -y install oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
      rm oracle-database-xe-18c-1.0-1.x86_64.rpm

      sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
      (echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

      # root user.
      cat ./oracle/root_bash_profile >> /root/.bash_profile

      echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> /root/.bash_profile
      source ~/.bash_profile

      # add setting connecting to XEPDB1 pragabble dababase.
      cat ./oracle/tnsnames.ora >> $ORACLE_HOME/network/admin/tnsnames.ora

      # oracle OS user.
      cat ./oracle/oracle_bash_profile >> /home/oracle/.bash_profile
      echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> /home/oracle/.bash_profile

      install ./oracle_set_log_mode /usr/local/bin/oracle_set_log_mode
      /usr/local/bin/oracle_set_log_mode archivelog

      # reference from [systemd launch rc-local](https://wiki.archlinux.org/index.php/User:Herodotus/Rc-Local-Systemd)
      cat ./oracle/oracle-xe-18c.service >> /etc/systemd/system/oracle-xe-18c.service

      install ./oracle/oracle_startup /usr/local/bin/oracle_startup
      chmod 755 /usr/local/bin/oracle_startup

      install ./oracle/oracle_shutdown /usr/local/bin/oracle_shutdown
      chmod 755 /usr/local/bin/oracle_shutdown

      systemctl daemon-reload

      # /usr/lib/systemd/systemd-sysv-install is not installed in fedora. reference from [fedora systemd](https://www.it-swarm-ja.tech/ja/fedora/systemdsysvinstall%E3%81%8C%E3%81%AA%E3%81%84%E3%81%9F%E3%82%81%E3%80%81fedora%E3%81%AE%E8%B5%B7%E5%8B%95%E6%99%82%E3%81%ABgrafana%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%9B%E3%82%93/962285807/)
      dnf install -y chkconfig

      systemctl enable oracle-xe-18c
    elif [ "${os}" == "rhel" ]; then
      wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm \
        && apt install -y ./powershell-lts_7.2* \
        && rm ./powershell-lts_7.2
    fi
  fi

}

function load_env {

  eval "$(
    cat .env | \
    sed 's/# .*$//' | \
    xargs -I {} echo export {};
  )"
}

function install_essential {

  if ! which git > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y git
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ]; then
      sudo dnf install -y git
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

  if ! which mlocate > /dev/null; then
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

function setup {

  # load
  load_env

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

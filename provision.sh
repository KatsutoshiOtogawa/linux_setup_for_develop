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
  elif ls /etc | grep oracle-release > /dev/null; then
    os_type=oracle
  elif ls /etc | grep centos-release > /dev/null; then
    os_type=centos
  elif cat /etc/os-release | grep "Amazon Linux 2" > /dev/null; then
    os_type=amazonlinux2
  elif ls /etc | grep redhat-release > /dev/null; then
    os_type=rhel
    # debian systems except ubuntu.
  elif ls /etc | grep debian_version > /dev/null; then
    os_type=debian
  elif ls /etc | grep lsb-release > /dev/null; then
    os_type=ubuntu
  elif ls /etc | grep SuSE-release > /dev/null; then
    os_type=SuSE
  elif ls /etc | grep arch-release > /dev/null && ! ls /etc | grep manjaro-release > /dev/null; then
    os_type=arch
  elif ls /etc | grep manjaro-release > /dev/null; then
    os_type=manjaro
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
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo dnf install -y gh
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo yum install -y gh
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo zypper -y ref
      sudo zypper -y install gh
    elif [ "${os}" == "arch" ] ||  "${os}" == "manjaro" ; then
      sudo pacman -S github-cli
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
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ] ; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -P .cache
      .cache/code*.deb
    elif [ "${os}" == "SuSE" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -P .cache
      .cache/code*.deb
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      yay -Sy visual-studio-code-bin
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
    elif [ "${os}" == "centos" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" -P .cache
      .cache/code*.deb
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      pacman -S docker docker-compose
    fi
  fi

  # install rootless mode
  if ! ls /home/$USER/bin | grep -e docker -e dockerd > /dev/null; then
    if [ "${os}" == "debian" ]; then
      : pass
    elif [ "${os}" == "ubuntu" ]; then
      : pass
    elif [ "${os}" == "fedora" ]; then
      : pass
    elif [ "${os}" == "rhel" ]; then
      : pass
    elif [ "${os}" == "centos" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      : pass
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S fuse-overlayfs
    fi

    sudo groupadd docker
    sudo usermod -aG docker $USER

    if ! grep ^$(whoami): /etc/subuid >> /dev/null; then
      su -c 'echo "$USER:100000:65536" >> /etc/subuid'
    fi
    if ! grep ^$(whoami): /etc/subgid >> /dev/null; then
      su -c 'echo "$USER:100000:65536" >> /etc/subgid'
    fi
    su -c "echo kernel.unprivileged_userns_clone=1 >> /etc/sysctl.conf"
    sudo sysctl --system
    curl -fsSL https://get.docker.com/rootless | sh
    echo export PATH=/home/$USER/bin:$PATH >> $HOME/.bashrc
    echo export DOCKER_HOST=unix:///run/user/1000/docker.sock >> $HOME/.bashrc

    # systemctl --user start docker
    # login したときにサービスを自動化するなら下を実行
    # sudo loginctl enable-linger $USER
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
  local file_path=$(dirname $0)

  if [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
    sudo pacman -S yay
  fi

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
    elif [ "${os}" == "centos" ]; then
      sudo yum install -y git
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y git
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install git
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S git
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add git
    fi
  fi

  if ! command -v wget > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y wget
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y wget
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install wget
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacmna -S wget
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add wget
    fi
  fi

  if ! command -v curl > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y curl
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y curl
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install curl
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacmna -S curl
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add curl
    fi
  fi

  if ! command -v vim > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y vim
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y vim
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vim
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S vim
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add vim
    fi
    su - -c 'echo "# set default browser for root." >> /root/.bashrc'
    su - -c 'echo "export EDITOR=$(command -v vim)" >> /root/.bashrc'
    echo "# set default browser for user." >> ~/.bashrc
    echo "export EDITOR=$(command -v vim)" >> ~/.bashrc

    # install vimplugins
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # set vim setting
    cp $file_path/.vimrc ~/

    # sync template file
    rsync -auv $file_path/vim ~/vim
  fi

  if ! command -v locate > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y mlocate
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y mlocate
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install mlocate
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S mlocate
    fi
  fi

  # environment variable display dont use,
  if ! command -v xclip > /dev/null && [ -z "${DISPLAY}" ] ; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y xclip
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y xclip
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo amazon-linux-extras install epel -y
      sudo yum install -y xclip
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install xclipboard
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S xclip
    fi
  fi

  # install pwmake, pwmake generate password following os security policy.
  if ! command -v pwmake > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y libpwquality-tools
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y libpwquality
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y libpwquality
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install libpwquality
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S libpwquality
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add libpwquality
    fi
  fi

}

function install_offensive_security {

  local os=$(os_type)
  local file_path=$(dirname $0)

  # add kali repository.
  if [ "${os}" == "debian" ]; then
    if cat /etc/apt/preferences.d | grep kali-linux > /dev/null; then
      echo "# kali-last-snapshot is " >> /etc/apt/sources.list
      echo "deb http://http.kali.org/kali kali-last-snapshot main contrib non-free" >> /etc/apt/sources.list
      echo "deb-src http://http.kali.org/kali kali-last-snapshot main contrib non-free" >> /etc/apt/sources.list
      sudo mkdir /etc/apt/preferences.d
      cat < $file_path/etc/apt/preferences.d/kali-linux.pref >> /etc/apt/preferences.d/kali-linux.pref
      if cat /etc/debian_version | grep 10. > /dev/null; then
        wget -qO- https://archive.kali.org/archive-key.asc | sudo apt-key add
      # Since apt-key is deprecated in debian 11 and later, use below.
      # apt-key will be removed in debian 12.
      # elif cat /etc/debian_version | grep 11. > /dev/null; then
      #   wget https://archive.kali.org/archive-key.asc
      #   gpg --no-default-keyring --keyring /etc/apt/trusted.gpg.d/kali-repository.gpg --import ./archive-key.asc
      fi
    fi
  fi
  if [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
    if [ ! -f /etc/pacman.d/blackarch-mirrorlist ]; then
      curl -O https://blackarch.org/strap.sh

      chmod u+x strap.sh
      sudo ./strap.sh

      rm ./strap.sh
      grep -n .jp /etc/pacman.d/blackarch-mirrorlist | \
        sed 's/:.*//g' | \
        xargs -I {} sudo sed -i "{}s/^#//" /etc/pacman.d/blackarch-mirrorlist

      #
      sudo pacman-mirrors --country all --api --protocols all --set-branch stable
      sudo pacman-mirrors --fasttrack
      sudo pacman -Syy
    fi
  fi
  if ! command -v msfdb > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      # depends on debian
      # metasploit-framework : Depends: ruby (>= 1:2.7) but 1:2.5.1 is to be installed
      #                   Depends: libc6 (>= 2.33) but 2.28-10 is to be installed
      #                   Depends: libpq5 (>= 14~beta3) but 11.14-0+deb10u1 is to be installed
      #                   Depends: libruby2.7 (>= 2.7.0) but it is not going to be installed
      #                   Depends: libstdc++6 (>= 11) but 8.3.0-6 is to be installed
      # /usr/bin/perl: error while loading shared libraries: libcrypt.so.1: cannot open shared object file: No such file or directory
      # dpkg: error processing package libc6:amd64 (--configure):
      #  installed libc6:amd64 package post-installation script subprocess returned error exit status 127
      # Errors were encountered while processing:
      #  libc6:amd64
      # sudo apt install -y ruby libc6 libpq5 libruby2.7 libstdc++6 -t kali-last-snapshot
      curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
      chmod u+x msfinstall
      sudo ./msfinstall
    elif [ "${os}" == "fedora" ]; then
      sudo dnf install -y metasploit
    elif [ "${os}" == "rhel" ]; then
      sudo dnf install -y metasploit
    elif [ "${os}" == "oracle" ]; then
      sudo dnf install -y metasploit
    elif [ "${os}" == "amazonlinux2" ]; then
      sudo yum install -y metasploit
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install metasploit
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S metasploit
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add git
    fi
  fi
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
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S nmap
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add git
    fi
  fi

  if ! command -v netdiscover > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y netdiscover
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y netdiscover
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install netdiscover
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S netdiscover
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add netdiscover
    fi
  fi

  if ! command -v dirb > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y dirb
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y dirb
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install dirb
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S dirb
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add dirb
    fi
  fi
  if ! command -v dirbuster > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y dirbuster
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y dirbuster
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install dirbuster
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S dirbuster
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add dirbuster
    fi
  fi
  if ! command -v nikto > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y nikto
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y nikto
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install nikto
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S nikto
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add nikto
    fi
  fi
  if ! command -v skipfish > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y skipfish
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y skipfish
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install skipfish
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -y skipfish
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add skipfish
    fi
  fi
  if ! command -v wapiti > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y wapiti
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y wapiti
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install wapiti
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S wapiti
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add wapiti
    fi
  fi

  if ! command -v joomscan > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y joomscan
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y joomscan
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install joomscan
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S joomscan
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add joomscan
    fi
  fi

  if ! command -v wpscan > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      # debian repository rusy-public-suffic is oldstable. debian 3.0.3+ds-1 is to be installed
      sudo apt install -y ruby-public-suffix -t kali-last-snapshot
      # Depends: ruby-public-suffix (>= 4.0.3)
      sudo apt install -y ruby-cms-scanner
      sudo apt install -y wpscan
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y wpscan
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install wpscan
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S wpscan
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add wpscan
    fi
  fi

  if ! command -v sqlmap > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y sqlmap
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y sqlmap
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install sqlmap
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S sqlmap
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add sqlmap
    fi
  fi

  if ! command -v netcat > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y netcat
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y netcat
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install netcat
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S netcan
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add netcat
    fi
  fi

  if ! command -v wireshark > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y wireshark
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y wireshark
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install wireshark
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S wireshark
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add wireshark
    fi
  fi

  if ! command -v nbtscan > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y nbtscan
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y nbtscan
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install nbtscan
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S nbtscan
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add nbtscan
    fi
  fi

  if ! command -v zaproxy > /dev/null || ! command -v owasp-zap > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y zaproxy
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y zaproxy
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install zaproxy
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S zaproxy
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add zaproxy
    fi
  fi

  if ! command -v unicornscan > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y unicornscan
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y unicornscan
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install unicornscan
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S unicornscan
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add unicornscan
    fi
  fi

  if ! command -v weevely > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y weevely
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y weevely
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install weevely
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S weevely
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add weevely
    fi
  fi

  if ! command -v beef-xss > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y beef-xss
      sudo systemctl disable beef-xss
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y beef-xss
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install beef-xss
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S beef
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add beef-xss
    fi
  fi

  if ! command -v hydra > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y hydra-gtk
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y hydra-gtk
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install hydra-gtk
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S hydra-gtk
      # hydrapaperのほうがメジャーでは？
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add hydra-gtk
    fi
  fi

  if ! command -v patator > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y patator
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y patator
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install patator
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S patator
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add patator
    fi
  fi

  if ! command -v enum4linux > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y enum4linux
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y enum4linux
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install enum4linux
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S enum4linux
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add enum4linux
    fi
  fi

  if ! command -v macchanger > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y macchanger
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y macchanger
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install macchanger
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S macchanger
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add macchanger
    fi
  fi

  if ! command -v aircrack-ng > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y aircrack-ng
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y aircrack-ng
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install aircrack-ng
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S aircrack-ng
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add aircrack-ng
    fi
  fi

  if ! command -v kismet > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y kismet
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y kismet
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install kismet
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S kismet
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add kismet
    fi
  fi

  if ! command -v wifite > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y wifite
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y wifite
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install wifite
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S wifite
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add wifite
    fi
  fi

  if ! command -v fern-wifi-cracker > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y fern-wifi-cracker
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y fern-wifi-cracker
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install fern-wifi-cracker
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S fern-wifi-cracker
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add fern-wifi-cracker
    fi
  fi

  if ! command -v anonsurf > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      : pass
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      : pass
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      : pass
    elif [ "${os}" == "OpenBSD" ]; then
      : pass
    fi
  fi

  # armitage depends on matasplot-framework
  if ! command -v armitage > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y armitage
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y armitage
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install armitage
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S armitage
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add armitage
    fi
  fi
  if ! command -v openvas > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y openvas
      sudo systemctl disable openvas
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y openvas
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install openvas
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S openvas
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add openvas
    fi
  fi
  if ! command -v burpsuite > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y burpsuite
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y burpsuite
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install burpsuite
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S burpsuite
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add burpsuite
    fi
  fi

  if ! command -v exploitdb > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y exploitdb
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y exploitdb
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install exploitdb
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S expoitdb
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add exploitdb
    fi
  fi

}

function install_libvirt {

  local os=$(os_type)

  if ! command -v virsh > /dev/null; then
    if [ ! -d ./.cache ]; then
      mkdir ./.cache
    fi

    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      : pass
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      : pass
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then

      # QEMU machine architecture
      sudo pacman -S libvirt qemu
      # hyper-visor use kvm
      # check kvm module
      lsmod | grep kvm
      # kvm_itel kvm 両方あれば良い。
      # amd ならkvm, kvm_amd
      echo modprobe kvm_${arch}

      # control libvirt domain(virtual machine) from terminal
      sudo pacman -S virt-install

      # gui tool for libvirt
      # virt-viewer is graphical console.
      sudo pacman -S virt-managere virt-viewer
      local kernel_version=$(uname -r | sed 's/\.//' | cut -c -3)
      # these tool using vmware player compile.
      sudo pacman -S linux${kerel_version}-headers make
      echo "if you use old linux kernel, update kenerl minor version."
      echo "sudo pacman -Syu linux${kernel_version} and reboot"

    fi

    # setting for non root user.

    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      : pass
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      : pass
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then

      # setting for kvm and qemu
      sudo usermod -aG kvm $USER
      local user_num=$(grep -n '#user = ' /etc/libvirt/qemu.conf | cut -d ':' -f 1)
      sudo sed -i "${user_num[0]}a user = \"$USER\"" /etc/libvirt/qemu.conf

      local group_num=$(grep -n '#group = ' /etc/libvirt/qemu.conf | cut -d ':' -f 1)
      sudo sed -i "${group_num[0]}a group = \"libvirt\"" /etc/libvirt/qemu.conf

      local dynamic_ownership_num=$(grep -n '#dynamic_ownership = ' /etc/libvirt/qemu.conf | cut -d ':' -f 1)
      sudo sed -i "${dynamic_ownership_num[0]}a dynamic_ownership = 1" /etc/libvirt/qemu.conf

      # setting for libvirt
      local unix_sock_group_num=$(grep -n '#unix_sock_group = ' /etc/libvirt/libvirtd.conf | cut -d ':' -f 1)
      sudo sed -i "${unix_sock_group_num[0]}a unix_sock_group = \"libvirt\"" /etc/libvirt/libvirtd.conf

      local unix_sock_ro_perms_num=$(grep -n '#unix_sock_ro_perms = ' /etc/libvirt/libvirtd.conf | cut -d ':' -f 1)
      sudo sed -i "${unix_sock_ro_perms_num[0]}a unix_sock_ro_perms = \"0777\"" /etc/libvirt/libvirtd.conf

      local unix_sock_rw_perms_num=$(grep -n '#unix_sock_rw_perms = ' /etc/libvirt/libvirtd.conf | cut -d ':' -f 1)
      sudo sed -i "${unix_sock_rw_perms_num[0]}a unix_sock_rw_perms = \"0770\"" /etc/libvirt/libvirtd.conf

      local auth_unix_ro_num=$(grep -n '#auth_unix_ro = ' /etc/libvirt/libvirtd.conf | cut -d ':' -f 1)
      sudo sed -i "${auth_unix_ro_num[0]}a auth_unix_ro = \"none\"" /etc/libvirt/libvirtd.conf

      local auth_unix_rw_num=$(grep -n '#auth_unix_rw = ' /etc/libvirt/libvirtd.conf | cut -d ':' -f 1)
      sudo sed -i "${auth_unix_rw_num[0]}a auth_unix_rw = \"none\"" /etc/libvirt/libvirtd.conf
      # /etc/libvirt/libvirtd.conf
      sudo usermod -aG libvirt $USER
    fi

    # install vagrant plugin
    vagrant plugin install vagrant-libvirt
    # install mutate is convert virtualbox to libvirt
    vagrant plugin install vagrant-mutate

    vagrant plugin install vagrant-vbguest vagrant-share
  fi

  if ! command -v vagrant > /dev/null; then
    if [ "${os}" == "debian" ]; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      echo "# vagrant repository" >> /etc/apt/sources.list
      echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" >> /etc/apt/sources.list
      sudo apt-get update && sudo apt-get install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "ubuntu" ]; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      sudo apt-get update && sudo apt-get install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add vagrant
    fi
  fi

}

function install_vmware {

  local os=$(os_type)

  if ! command -v vmplayer > /dev/null; then
    if [ ! -d ./.cache ]; then
      mkdir ./.cache
    fi

    local user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:97.0) Gecko/20100101 Firefox/97.0"
    local vmware_player_url=https://www.vmware.com/go/getplayer-linux
    wget --content-disposition $vmware_player_url --user-agent="$(echo ${user_agent})" -P .cache/

    chmod u+x .cache/VMware-Player-Full*.bundle
    ./.cache/VMware-Player-Full*.bundle
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      : pass
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      : pass
    elif [ "${os}" == "SuSE" ]; then
      : pass
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then

      local kernel_version=$(uname -r | sed 's/\.//' | cut -c -3)
      # these tool using vmware player compile.
      sudo pacman -S linux${kerel_version}-headers make
      echo "if you use old linux kernel, update kenerl minor version."
      echo "sudo pacman -Syu linux${kernel_version} and reboot"

    fi

    echo "open vmware-player and set initial config!"
  fi

  if ! command -v vagrant > /dev/null; then
    if [ "${os}" == "debian" ]; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      echo "# vagrant repository" >> /etc/apt/sources.list
      echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" >> /etc/apt/sources.list
      sudo apt-get update && sudo apt-get install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "ubuntu" ]; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      sudo apt-get update && sudo apt-get install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add vagrant
    fi
  fi

}

function install_virtualbox {

  local os=$(os_type)

  if ! command -v virtualbox > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      wget https://download.virtualbox.org/virtualbox/6.1.14/virtualbox-6.1_6.1.14-140239~Ubuntu~bionic_amd64.deb
      sudo apt install -y ./virtualbox*.deb
      rm ./virtualbox*.deb
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y virtualbox
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install virtualbox
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      local kernel_version=$(uname -r | sed 's/\.//' | cut -c -3)
      sudo pacman -S linux${kernel_version}-virtualbox-host-modules
      # sudo pacman -S linux${kernel_version}-headers
      sudo pacman -S virtualbox
      # kernelのバージョンとあっているか確認
      # ls -1 /lib/modules | grep MANJARO

      echo "if you use old linux kernel, update kenerl minor version."
      echo "sudo pacman -Syu linux${kernel_version} and reboot"
      sudo vboxreload
      # sudo pacman -S dkms
      #
      # local virtualbox_version=$(pacman -Q virtualbox | awk -F ' ' '{print $2}' | sed 's/-.*$//')
      # local =$(uname -m)
      # local =$(uname -rm | sed 's| |/|' | sed 's/MANJARO/ARCH/')
      # sudo dkms install vboxhost/$virtualbox_version -k $(uname -rm | sed 's| |/|')
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add virtualbox
    fi
  fi

  if ! command -v vagrant > /dev/null; then
    if [ "${os}" == "debian" ]; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      echo "# vagrant repository" >> /etc/apt/sources.list
      echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" >> /etc/apt/sources.list
      sudo apt-get update && sudo apt-get install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "ubuntu" ]; then
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      sudo apt-get update && sudo apt-get install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S vagrant
      vagrant plugin install vagrant-vbguest
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add vagrant
    fi
    echo export VAGRANT_DEFAULT_PROVIDER=virtualbox >> $HOME/.bashrc
  fi

}

function install_mkcert {

  local os=$(os_type)

  if ! command -v mkcert > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
      mv mkcert* mkcert
      sudo install ./mkcert /usr/bin/
      rm ./mkcert
      # sudp apt install -y mkcert
      # install certutil
      sudo apt install -y libnss3-tools
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
      mv mkcert* mkcert
      sudo install ./mkcert /usr/bin/
      rm ./mkcert
      sudo dnf install -y nss-tools
    elif [ "${os}" == "SuSE" ]; then
      wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
      mv mkcert* mkcert
      sudo install ./mkcert /usr/bin/
      rm ./mkcert
      sudo zypper install mozilla-nss-tools
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S mkcert
      sudo pacman -S nss
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add mkcert
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

  if [ "${os}" == "debian" ]; then
    :pass
  elif [ "${os}" == "ubuntu" ]; then
    :pass
  elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
    # fix language pack missing. this is a rhel8 and centos8 bug. (https://unixcop.com/fix-problem-failed-to-set-locale-defaulting-to-c-utf-8-in-centos-8-rhel-8/)
    sudo dnf install -y glibc-all-langpacks langpacks-en
  elif [ "${os}" == "SuSE" ]; then
    :pass
  elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
    :pass
  elif [ "${os}" == "OpenBSD" ]; then
    :pass
  fi
}

function set_input_method {

  local os=$(os_type)

  if ! command -v fcitx-configtool > /dev/null; then
    if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
      sudo apt install -y fcitx-mozc
      # after reboot, execute "fcitx-configtool" and add mozc.
    elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
      sudo dnf install -y fcitx-mozc
    elif [ "${os}" == "SuSE" ]; then
      sudo zypper -y install fcitx-mozc
    elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
      sudo pacman -S fctix-mozc fctix-configtool
    elif [ "${os}" == "OpenBSD" ]; then
      sudo pkg_add fcitx-mozc
    fi
    echo "after reboot, execute fcitx-configtool and add mozc."
  fi

}

function set_package_mirror {

  if [ "${os}" == "debian" ] || [ "${os}" == "ubuntu" ]; then
    : pass
  elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
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
  local os=$(os_type)
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

function set_mirror_stable_and_fast_mirror {

  local os=$(os_type)
  if [ "${os}" == "debian" ]; then
  elif [ "${os}" == "ubuntu" ]; then
  elif [ "${os}" == "fedora" ] || [ "${os}" == "rhel" ] || [ "${os}" == "oracle" ] || [ "${os}" == "centos" ]; then
    sudo dnf install -y vagrant
    vagrant plugin install vagrant-vbguest
  elif [ "${os}" == "SuSE" ]; then
    sudo zypper -y install vagrant
    vagrant plugin install vagrant-vbguest
  elif [ "${os}" == "arch" ] || [ "${os}" == "manjaro" ]; then
    sudo pacman-mirrors --country all --api --protocols all --set-branch stable
    sudo pacman-mirrors --fasttrack
  elif [ "${os}" == "OpenBSD" ]; then
    sudo pkg_add vagrant
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

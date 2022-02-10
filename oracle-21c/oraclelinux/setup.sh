#!/usr/bin/bash

function main {

  local os
  if cat /etc/oracle-release | grep 7. > /dev/null; then
    os=oraclelinux7
  elif cat /etc/oracle-release | grep 8. > /dev/null; then
    os=oraclelinux8
  else
    echo "oracle 21c is oracle linux 7 or 8 only install!" >&2
    return 1
  fi

  if [ ! -d ./.cache ]; then
    mkdir ./.cache
  fi

  local file_dir=$(dirname $0)/../../oracle-21c

  dnf -y install oracle-database-preinstall-21c

  # silent install oracle database.
  if [ ! -d /xe_logs ]; then
    mkdir /xe_logs
  fi

  # set password not to contain symbol. oracle password can't be used symbol.
  ORACLE_PASSWORD=`pwmake 128 | sed 's/\W//g'`

  if [ ! ${os} = "oraclelinux7" ]; then
    if [ ! -f ./.cache/oracle-database-xe-21c*ol7* ]; then
      wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm -P ./.cache

    fi
    echo installing oracle database...
    dnf -y localinstall ./.cache/oracle-database-xe-21c*ol7*.rpm > /xe_logs/XEsilentinstall.log 2>&1
  elif [ ! ${os} = "oraclelinux8" ]; then
    if [ ! -f ./.cache/oracle-database-xe-21c*ol8* ]; then
      wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm -P ./.cache

      # sha256sum ./.cache/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm \
      #   -c "f8357b432de33478549a76557e8c5220ec243710ed86115c65b0c2bc00a848db  ./.cache/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"
    fi
    echo installing oracle database...
    dnf -y localinstall ./.cache/oracle-database-xe-21c*ol8*.rpm > /xe_logs/XEsilentinstall.log 2>&1
  fi

  # echo finish downloading oracle database!
  # dnf -y localinstall ./.cache/oracle-database-xe-21c*ol7*.rpm > /xe_logs/XEsilentinstall.log 2>&1
  # dnf install -y oracle-database-xe-21c
  sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-21c.conf
  (echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-21c configure >> /xe_logs/XEsilentinstall.log 2>&1

  # root user.
  if ! grep "set oracle environment variable" /root/.bashrc > /dev/null; then
    cat $file_dir/root_bashrc >> /root/.bashrc
  fi

  sed -i '/export ORACLE_PASSWORD=/d' /root/.bashrc
  echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> /root/.bashrc
  source ~/.bashrc

  # add setting connecting to XEPDB1 pragabble dababase.
  cat $file_dir/tnsnames.ora >> $ORACLE_HOME/network/admin/tnsnames.ora

  # oracle OS user.
  if ! grep "set oracle environment variable" /home/oracle/.bashrc > /dev/null; then
    cat $file_dir/oracle_bashrc >> /home/oracle/.bashrc
  fi
  sed -i '/export ORACLE_PASSWORD=/d' /home/oracle/.bashrc
  echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> /home/oracle/.bashrc

  # install $file_dir/oracle_set_log_mode /usr/local/bin/oracle_set_log_mode
  # /usr/local/bin/oracle_set_log_mode archivelog

  # # reference from [systemd launch rc-local](https://wiki.archlinux.org/index.php/User:Herodotus/Rc-Local-Systemd)
  # if [ ! -f /etc/systemd/system/oracle-xe-21c.service ]; then
  #   cat $file_dir/oracle-xe-21c.service >> /etc/systemd/system/oracle-xe-21c.service
  # fi

  # install $file_dir/oracle_startup /usr/local/bin/oracle_startup
  # chmod 755 /usr/local/bin/oracle_startup

  # install $file_dir/oracle_shutdown /usr/local/bin/oracle_shutdown
  # chmod 755 /usr/local/bin/oracle_shutdown

  # systemctl daemon-reload

  # # /usr/lib/systemd/systemd-sysv-install is not installed in fedora. reference from [fedora systemd](https://www.it-swarm-ja.tech/ja/fedora/systemdsysvinstall%E3%81%8C%E3%81%AA%E3%81%84%E3%81%9F%E3%82%81%E3%80%81fedora%E3%81%AE%E8%B5%B7%E5%8B%95%E6%99%82%E3%81%ABgrafana%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%9B%E3%82%93/962285807/)
  # dnf install -y chkconfig

  # systemctl enable oracle-xe-21c


  # rm oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
  # rm oracle-database-xe-18c-1.0-1.x86_64.rpm
}


main $@

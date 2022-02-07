#!/usr/bin/bash

function main {

  local file_dir=$(dirname $0)/../oracle

  # 管理者権限チェック

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
  dnf -y localinstall oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
  rm oracle-database-xe-18c-1.0-1.x86_64.rpm

  sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
  (echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

  # root user.
  cat $file_dir/root_bash_profile >> /root/.bash_profile

  echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> /root/.bash_profile
  source ~/.bash_profile

  # add setting connecting to XEPDB1 pragabble dababase.
  cat $file_dir/tnsnames.ora >> $ORACLE_HOME/network/admin/tnsnames.ora

  # oracle OS user.
  cat $file_dir/oracle_bash_profile >> /home/oracle/.bash_profile
  echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> /home/oracle/.bash_profile

  install $file_dir/oracle_set_log_mode /usr/local/bin/oracle_set_log_mode
  /usr/local/bin/oracle_set_log_mode archivelog

  # reference from [systemd launch rc-local](https://wiki.archlinux.org/index.php/User:Herodotus/Rc-Local-Systemd)
  cat $file_dir/oracle-xe-18c.service >> /etc/systemd/system/oracle-xe-18c.service

  install $file_dir/oracle_startup /usr/local/bin/oracle_startup
  chmod 755 /usr/local/bin/oracle_startup

  install $file_dir/oracle_shutdown /usr/local/bin/oracle_shutdown
  chmod 755 /usr/local/bin/oracle_shutdown

  systemctl daemon-reload

  # /usr/lib/systemd/systemd-sysv-install is not installed in fedora. reference from [fedora systemd](https://www.it-swarm-ja.tech/ja/fedora/systemdsysvinstall%E3%81%8C%E3%81%AA%E3%81%84%E3%81%9F%E3%82%81%E3%80%81fedora%E3%81%AE%E8%B5%B7%E5%8B%95%E6%99%82%E3%81%ABgrafana%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%9B%E3%82%93/962285807/)
  dnf install -y chkconfig

  systemctl enable oracle-xe-18c
}


main $@

#!/bin/bash

installMariaDb ()
{
  echo -e "${YELLOW}Installing MariaDB...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-get install -y software-properties-common dirmngr
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    add-apt-repository "deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.5/$DIST $CODE main"
    apt-get update
    apt-get install -y mariadb-server
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    echo -e "[mariadb]\n\
      name = MariaDB\n\
      baseurl = http://nyc2.mirrors.digitalocean.com/mariadb/yum/10.5/$DIST$VER-amd64\n\
      gpgkey=http://nyc2.mirrors.digitalocean.com/mariadb/yum/RPM-GPG-KEY-MariaDB\n\
      gpgcheck=1" | sed -e "s|^[[:space:]]*||" > /etc/yum.repos.d/mariadb.repo
    yum update -y
    if [ $VER = 7 ]; then
      yum install -y MariaDB-server MariaDB-client
    elif [ $VER = 8 ]; then
      if [ $DIST = "centos" ]; then
        dnf install -y boost-program-options
        dnf install -y MariaDB-server MariaDB-client --disablerepo=AppStream
      elif [ $DIST = "rhel" ]; then
        dnf install -y boost-program-options
        dnf install -y MariaDB-server MariaDB-client --disablerepo=rhel-8-for-x86_64-appstream-rpms
      fi
    fi
  fi
  systemctl start mariadb
  systemctl enable mariadb
  MYSQL_PASS=$(
    whiptail --passwordbox "Please set a password for user 'root': " 8 42 --title "MariaDB Root Password" --nocancel \
    3>&1 1>&2 2>&3 \
  )
  mysqladmin -u root password $MYSQL_PASS
  echo -e "${GREEN}MariaDB Installed!${NC}\n"
}

main ()
{
  if [ "$USER" == "root" ]; then
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh" | bash
    installMariaDb
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

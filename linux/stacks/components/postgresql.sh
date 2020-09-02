#!/bin/bash

installPostgreSql ()
{
  echo -e "${YELLOW}Installing PostgreSQL...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    wget -P /tmp https://www.postgresql.org/media/keys/ACCC4CF8.asc
    apt-key add /tmp/ACCC4CF8.asc
    add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $CODE-pgdg main"
    apt-get update
    apt-get install -y postgresql-12 postgresql-client-12
    systemctl start postgresql
    systemctl enable postgresql
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    yum update -y
    if [ $VER = 7 ]; then
      yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
      yum install -y postgresql12-server
    elif [ $VER = 8 ]; then
      dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
      dnf -qy module disable postgresql
      dnf install -y postgresql-server
    fi
    /usr/pgsql-12/bin/postgresql-12-setup initdb
    systemctl start postgresql-12
    systemctl enable postgresql-12
  fi
  PG_PASS=$(
    whiptail --passwordbox "Please set a password for user 'postgres': " 8 46 --title "PostgreSQL Postgres Password" --nocancel \
    3>&1 1>&2 2>&3 \
  )
  sudo -u postgres psql -U postgres -d postgres -c "ALTER USER POSTGRES WITH PASSWORD '$PG_PASS';"
  echo -e "${GREEN}PostgreSQL Installed!${NC}\n"
}

main ()
{
  if [ "$USER" == "root" ]; then
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh" | bash
    installPostgreSql
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

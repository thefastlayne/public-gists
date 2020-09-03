#!/bin/bash
#  @title LEPP Installer
#  @author Kamaran Layne <github.com/KamaranL>
#  @system Debian 8,9 | Ubuntu 16,18,20 | CentOS 7,8 | RedHat Enterprise Linux 7,8
#  @description This script will install Nginx 1.x.x, PostgreSQL 12.x, PHP 7.3.x and phpPgAdmin 7.12.x

checkForUpdates ()
{
  echo -e "Upgrading newly installed packages...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-get upgrade -y
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    yum update -y
  fi
}

restartServices ()
{
  echo -e "Restarting all services...${NC}\n"
  systemctl restart nginx
  nginx -s reload
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    systemctl restart postgresql
    systemctl restart php7.4-fpm
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    systemctl restart postgresql-12
    systemctl restart php-fpm
  fi
}

main ()
{
  if [ "$USER" == "root" ]; then
    source <(curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh)
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/nginx.sh" | bash
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/postgresql.sh" | bash
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/php.sh" | bash -s -- --postgresql
    checkForUpdates
    restartServices
    echo -e "Your LEPP stack is successfully installed and configured.\nYou can access your webserver at ${YELLOW}$(hostname -I)${NC}"
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

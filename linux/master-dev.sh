#!/bin/bash
#  @title Master-Dev Installer
#  @author Kamaran Layne <github.com/KamaranL>
#  @system Debian 8,9 | Ubuntu 16,18,20 | CentOS 7,8 | RedHat Enterprise Linux 7,8
#  @description Select what stack OR components you want to install

__construct ()
{
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
  NC='\033[0m'
  DIST=$(awk -F= '/^ID=/{print $2}' /etc/os-release | sed 's|"||g')
  VER=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release | sed 's|"||g' | sed -e "s|[.].*||")
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    WEB_ROOT="/var/www/"
    PHP_SOCKET="unix:/run/php/php7.4-fpm.sock"
    DBM_ROOT="/usr/share/"
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    WEB_ROOT="/usr/share/nginx/"
    PHP_SOCKET="unix:/run/php-fpm/www.sock"
    DBM_ROOT="$WEB_ROOT"
  fi
  MY_GITHUB="https://github.com/KamaranL/"
  THEFASTLAYNE_WEB="https://www.thefastlayne.net/"
  THEFASTLAYNE_GITHUB="https://github.com/TheFastLayne/"
}

installPrerequisites ()
{
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-get clean
    rm -rf /var/cache/apt/archives/*
    apt-get update
    apt-get install -y wget tar bzip2 curl ca-certificates apt-transport-https
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    yum clean all
    rm -rf /var/cache/yum/*
    yum -y update
    yum install -y tar wget bzip2 curl yum-utils epel-release
  fi
}

selectStack ()
{
  STACK=$(
    whiptail --title "Popular Tech Stacks" --radiolist "Select a tech stack to install or choose custom for individual components: " 12 56 5 \
      "LEMP" "Nginx, MariaDB, PHP " off \
      "LEPP" "Nginx, PostgreSQL, PHP " off \
      "LEPD" "Nginx, PostgreSQL, Dotnet " off \
      "LEMD" "Nginx, Microsoft SQL, Dotnet " off \
      "Custom" "Select what components to install " off \
      3>&1 1>&2 2>&3 \
  )
  case $STACK in
    "LEMP") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lemp.sh | bash;;
    "LEPP") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lepp.sh | bash;;
    "LEPD") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lepd.sh | bash;;
    "LEMD") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lemd.sh | bash;;
    "Custom") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/custom.sh | bash;;
  esac
}

##############
# MAIN       #
##############
#
#
main ()
{
  if [ "$USER" == "root" ]; then
    __construct
    installPrerequisites
    selectStack
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

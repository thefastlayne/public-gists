#!/bin/bash

__construct ()
{
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
  NC='\033[0m'
  DIST=$(awk -F= '/^ID=/{print $2}' /etc/os-release | sed 's|"||g')
  VER=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release | sed 's|"||g' | sed -e "s|[.].*||")
  QUIET="> /dev/null 2>&1"
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

main ()
{
  if [ "$USER" == "root" ]; then
    __construct
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

#!/bin/bash
#  @title Master-Dev Installer
#  @author Kamaran Layne <github.com/KamaranL>
#  @system Debian 8,9 | Ubuntu 16,18,20 | CentOS 7,8 | RedHat Enterprise Linux 7,8
#  @description Select what stack OR components you want to install

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
    "LEMP") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lemp.sh | bash ;;
    "LEPP") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lepp.sh | bash ;;
    "LEPD") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lepd.sh | bash ;;
    "LEMD") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lemd.sh | bash ;;
    "Custom") curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/custom.sh | bash ;;
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
    selectStack
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

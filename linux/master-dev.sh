#!/bin/bash
#  @title Master-Dev Installer
#  @author Kamaran Layne <github.com/KamaranL>
#  @system Debian 8,9 | Ubuntu 16,18,20 | CentOS 7,8 | RedHat Enterprise Linux 7,8
#  @description Select what stack OR stack components you want to install

installPrerequisites ()
{
  echo -e "${YELLOW}Installing prerequisites...${NC}\n"
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
  echo -e "${GREEN}Prerequisites installed!${NC}\n"
}

installStack ()
{
  echo -e "${YELLOW}Launching Stack Selection...${NC}\n"
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
    "LEMP") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lemp.sh" | bash;;
    "LEPP") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lepp.sh" | bash;;
    "LEPD") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lepd.sh" | bash;;
    "LEMD") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/lemd.sh" | bash;;
    "Custom") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/custom.sh" | bash;;
  esac
}

checkForUpdates ()
{
  echo -e "${YELLOW}Upgrading newly installed packages...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-get upgrade -y
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    yum update -y
  fi
}

restartServices ()
{
  echo -e "${YELLOW}Restarting all services...${NC}\n"
  SERVICES=(nginx mariadb postgresql postgresql-12 php7.4-fpm php-fpm)
  for service in "${SERVICES[@]}"; do
    if systemctl status "$service" "$QUIET"; then
      systemctl restart "$service"
    fi
  done
}

##############
# MAIN       #
##############
#
#
main ()
{
  if [ "$USER" == "root" ]; then
    source <(curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh)
    installPrerequisites
    installStack
    checkForUpdates
    restartServices
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

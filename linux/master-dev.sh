#!/bin/bash

##############
#   STACKS   #
##############
#
#
installLEMPStack ()
{

}

installLEPPStack ()
{

}

installLEPDStack ()
{

}

installLEMDStack ()
{

}

##############
#  WHIPTAIL  #
##############
#
#
selectCustom ()
{
  whiptail --title "Custom Stack" --checklist --separate-output "Select custom components to install: " 19 56 15 \
    "Nginx" "A high performance load balancer, web server, & reverse proxy" off \
    "MariaDB" "A community developed fork of the MySQL database management system" off \
    "PostgreSQL" "A powerful, open source object-relational database system" off \
    "SQLite" "A small, fast, self-contained, high-reliability, full-featured, SQL database engine" off \
    "Microsoft SQL" "A relational database management system developed by Microsoft" off \
    "MongoDB" "A general purpose, document based, distributed NoSQL database" off \
    "Redis" "An open-source, in-memory data structure store, used as a database, cache and message broker" off \
    "PHP" "A general-purpose scripting language, especially suited to server-side web development" off \
    "Dotnet Core" "A cross-platform version of Microsoft's .NET for building websites, services, and console apps" off \
    "Node" "An open-source, cross-platform, JavaScript runtime environment that executes JavaScript on the server" off \
    "React" "An open-source JavaScript library for building UI components, developed by Facebook" off \
    "Vue" "An open-source JavaScript framework for building UI compnents and Single Page Applications" off \
    "Angular" "A TypeScript-based open-source web application framework, developed by Google" off \
    "Composer" "An application-level package manager for the PHP scripting language" off \
    "Ruby on Rails" "A server-side web application framework written in the Ruby programming language" off \
    "Laravel" "A free, open-source PHP web framework intended for development of MVC web applications, based on Symfony" off \
  2>COMPONENTS

  while read COMPONENT; do
    case $COMPONENT in
      "") install ;;
      "") install ;;
      "") install ;;
      "") install ;;
      "") install ;;
      "") install ;;
      "") install ;;
      "") install ;;
      "") install ;;
      # "") install ;;
    esac
  done < COMPONENTS
}

selectStack ()
{
  STACK=$(
    whiptail --title "Popular Tech Stacks" --radiolist "Select a tech stack to install or choose custom for individual components : " 12 56 5 \
      "LEMP" "Nginx, MariaDB, PHP " off \
      "LEPP" "Nginx, PostgreSQL, PHP " off \
      "LEPD" "Nginx, PostgreSQL, Dotnet " off \
      "LEMD" "Nginx, Microsoft SQL, Dotnet " off \
      "Custom" "Select what components to install " off \
      3>&1 1>&2 2>&3 \
  )
  case $STACK in
    "LEMP") installLEMPStack
      ;;
    "LEPP") installLEPPStack
      ;;
    "LEPD") installLEPDStack
      ;;
    "LEMD") installLEMDStack
      ;;
    "Custom") selectCustom
      ;;
  esac
}

##############
#    MAIN    #
##############
#
#
main ()
{
  if [ "$USER" == "root" ]; then
    __construct
    selectStack
    if [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
      configureSeLinux
      configureFirewall
    fi
    setupDemoPage
    checkForUpdates
    echo -e "Your $STACK stack is successfully installed and configured.\nYou can access your webserver at ${YELLOW}$(hostname -I)${NC}"
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

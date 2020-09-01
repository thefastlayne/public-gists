#!/bin/bash
#  @title Custom Component Script
#  @author Kamaran Layne <github.com/KamaranL>
#  @system Debian 8,9 | Ubuntu 16,18,20 | CentOS 7,8 | RedHat Enterprise Linux 7,8
#  @description Select what components you want to install and it installs your dev environment for you

##############
# WEB SERVER #
##############
#
#



##############
# DATABASE   #
##############
#
#



##############
# BACKEND    #
##############
#
#


##############
# FRONTEND   #
##############
#
#


selectCustom ()
{
  whiptail --title "Custom Stack" --checklist --separate-output "Select custom components to install: " 25 100 15 \
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
      # "") install ;;
    esac
  done < COMPONENTS
}

##############
# MAIN       #
##############
#
#
main ()
{
  if [ "$USER" == "root" ]; then
    selectCustom
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

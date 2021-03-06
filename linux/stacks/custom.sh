#!/bin/bash

installCustom ()
{
  whiptail --title "Custom Stack" --checklist --separate-output "Select custom components to install: " 23 134 16 \
    "Nginx" "A high performance load balancer, web server, & reverse proxy " off \
    "MariaDB" "A community developed fork of the MySQL database management system " off \
    "PostgreSQL" "A powerful, open source object-relational database system " off \
    "SQLite" "A small, fast, self-contained, high-reliability, full-featured, SQL database engine " off \
    "Microsoft SQL" "A relational database management system developed by Microsoft " off \
    "MongoDB" "A general purpose, document based, distributed NoSQL database " off \
    "Redis" "An open-source, in-memory data structure store, used as a database, cache and message broker " off \
    "PHP" "A general-purpose scripting language, especially suited to server-side web development " off \
    "Dotnet Core" "A cross-platform version of Microsoft's .NET for building websites, services, and console apps " off \
    "Node" "An open-source, cross-platform, JavaScript runtime environment that executes JavaScript on the server " off \
    "React" "An open-source JavaScript library for building UI components, developed by Facebook" off \
    "Vue" "An open-source JavaScript framework for building UI compnents and Single Page Applications " off \
    "Angular" "A TypeScript-based open-source web application framework, developed by Google " off \
    "Composer" "An application-level package manager for the PHP scripting language " off \
    "Ruby on Rails" "A server-side web application framework written in the Ruby programming language " off \
    "Laravel" "A free, open-source PHP web framework intended for development of MVC web applications, based on Symfony " off \
  2>COMPONENTS

  while read COMPONENT; do
    case $COMPONENT in
      "Nginx") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/nginx.sh" | bash;;
      "MariaDB") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/mariadb.sh" | bash;;
      "PostgreSQL") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/postgresql.sh" | bash;;
      "SQLite") curl -s "" | bash;;
      "Microsoft SQL") curl -s "" | bash;;
      "MongoDB") curl -s "" | bash;;
      "Redis") curl -s "" | bash;;
      "PHP") curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/php.sh" | bash -s -- --mariadb --postgresql;;
      "Dotnet Core") curl -s "" | bash;;
      "Node") curl -s "" | bash;;
      "React") curl -s "" | bash;;
      "Vue") curl -s "" | bash;;
      "Angular") curl -s "" | bash;;
      "Composer") curl -s "" | bash;;
      "Ruby on Rails") curl -s "" | bash;;
      "Laravel") curl -s "" | bash;;
    esac
  done < COMPONENTS
}

main ()
{
  if [ "$USER" == "root" ]; then
    source <(curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh)
    installCustom
    echo -e "${GREEN}Your Custom stack is successfully installed and configured.${NC}\nYou can access your webserver at ${YELLOW}$(hostname -I)${NC}"
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

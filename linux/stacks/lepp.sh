#!/bin/bash

main ()
{
  if [ "$USER" == "root" ]; then
    source <(curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh)
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/nginx.sh" | bash
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/postgresql.sh" | bash
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/php.sh" | bash -s -- --postgresql
    echo -e "${GREEN}Your LEPP stack is successfully installed and configured.${NC}\nYou can access your webserver at ${YELLOW}$(hostname -I)${NC}"
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

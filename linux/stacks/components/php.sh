#!/bin/bash

installPhpmyadmin ()
{
  echo -e "${YELLOW}Installing phpMyAdmin...${NC}\n"
  wget -P /tmp https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz
  tar xzf /tmp/phpMyAdmin-5.0.2-english.tar.gz -C /usr/share
  mv /usr/share/phpMyAdmin-5.0.2-english "$DBM_ROOT"phpmyadmin
  cp "$DBM_ROOT"phpmyadmin/config.sample.inc.php "$DBM_ROOT"phpmyadmin/config.inc.php
  mkdir /etc/nginx/aliases

  # /etc/nginx/aliases/phpmyadmin.conf
  echo -e '# Alias /phpmyadmin
    location /phpmyadmin {
      index index.php index.html index.htm;
      root '$DBM_ROOT';
      location ~ ^/phpmyadmin/(.+\.php)$ {
        try_files $uri =404;
        root '$DBM_ROOT';
        include global/fastcgi_php.conf;
      }
      location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        root '$DBM_ROOT';
      }
    }
    location /phpMyAdmin {
      rewrite ^/* /phpmyadmin last;
    }' > /etc/nginx/aliases/phpmyadmin.conf
  sed -i "s|define('CONFIG_DIR', '');|define('CONFIG_DIR', './');|g" "$DBM_ROOT"phpmyadmin/libraries/vendor_config.php
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    mkdir "$DBM_ROOT"phpmyadmin/libraries/tmp
    chown -R www-data:www-data "$DBM_ROOT"phpmyadmin
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    sed -i "s|define('TEMP_DIR', ROOT_PATH . 'tmp/');|define('TEMP_DIR', '/tmp/');|g" "$DBM_ROOT"phpmyadmin/libraries/vendor_config.php
    chown -R nginx:nginx "$DBM_ROOT"phpmyadmin
  fi
  BFS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  sed -i "s|cfg\['blowfish_secret'\] = '';|cfg\['blowfish_secret'\] = '$BFS';|g" "$DBM_ROOT"phpmyadmin/config.inc.php
  PMA_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
  PMA_QUERY="CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$PMA_PASS'; GRANT USAGE ON *.* TO 'phpmyadmin'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; CREATE DATABASE IF NOT EXISTS \`phpmyadmin\`; GRANT ALL PRIVILEGES ON \`phpmyadmin\`.* TO 'phpmyadmin'@'localhost'; FLUSH PRIVILEGES;"
  mysql -e "$PMA_QUERY"
  mysql -u root -D phpmyadmin < "$DBM_ROOT"phpmyadmin/sql/create_tables.sql
  chmod -R 0775 "$DBM_ROOT"phpmyadmin
  echo -e "${GREEN}phpMyAdmin Installed!\n"
}

installPhppgadmin ()
{
  echo -e "${YELLOW}Installing phpPgAdmin...${NC}\n"
  wget -P /tmp https://github.com/phppgadmin/phppgadmin/releases/download/REL_7-12-1/phpPgAdmin-7.12.1.tar.gz
  tar xzf /tmp/phpPgAdmin-7.12.1.tar.gz -C /usr/share
  mv /usr/share/phpPgAdmin-7.12.1 "$DBM_ROOT"phppgadmin
  cp "$DBM_ROOT"phppgadmin/conf/config.inc.php-dist "$DBM_ROOT"phppgadmin/conf/config.inc.php
  mkdir /etc/nginx/aliases

  # /etc/nginx/aliases/phppgadmin.conf
  echo -e '# Alias /phppgadmin
    location /phppgadmin {
      index index.php index.html index.htm;
      root '$DBM_ROOT';
      location ~ ^/phppgadmin/(.+\.php)$ {
        try_files $uri =404;
        root '$DBM_ROOT';
        include global/fastcgi_php.conf;
      }
      location ~* ^/phppgadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        root '$DBM_ROOT';
      }
    }
    location /phpPgAdmin {
      rewrite ^/* /phppgadmin last;
    }
  ' > /etc/nginx/aliases/phppgadmin.conf
  sed -i "s|conf\['extra_login_security'\] = true;|conf\['extra_login_security'\] = false;|g" "$DBM_ROOT"phppgadmin/conf/config.inc.php
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    sed -i "s|  trust|  md5|g" /etc/postgresql/12/main/pg_hba.conf
    sed -i "s|  peer|  md5|g" /etc/postgresql/12/main/pg_hba.conf
    chown -R www-data:www-data "$DBM_ROOT"phppgadmin
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    sed -i "s|  peer|  md5|g" /var/lib/pgsql/12/data/pg_hba.conf
    chown -R nginx:nginx "$DBM_ROOT"phppgadmin
  fi
  chmod -R 0775 "$DBM_ROOT"phppgadmin
  echo -e "${GREEN}phpPgAdmin Installed!\n"
}

installPhp ()
{
  echo -e "${YELLOW}Installing PHP...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    if [ $DIST = "ubuntu" ]; then
      add-apt-repository -y ppa:ondrej/php
    elif [ $DIST = "debian" ]; then
      wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
      add-apt-repository "deb https://packages.sury.org/php/ $CODE main"
    fi
    apt-get update
    apt-get install -y php7.4-bcmath php7.4-bz2 php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-fpm php7.4-gd php-imagick php7.4-imap php7.4-intl php7.4-json php7.4-ldap php7.4-mbstring php7.4-mysql php-pear php7.4-pgsql php7.4-soap php7.4-tidy php7.4-xml php7.4-xmlrpc php7.4-zip
    sed -i "s|;date.timezone =|date.timezone = $(sed 's|\/|\\\/|' /etc/timezone)|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=bz2|extension=bz2|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=curl|extension=curl|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=fileinfo|extension=fileinfo|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=gd2|extension=gd2|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=gettext|extension=gettext|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=intl|extension=intl|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=imap|extension=imap|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=ldap|extension=ldap|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=mbstring|extension=mbstring|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=exif|extension=exif|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=mysqli|extension=mysqli|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=openssl|extension=openssl|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=pdo_mysql|extension=pdo_mysql|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=pdo_pgsql|extension=pdo_pgsql|g" /etc/php/7.4/fpm/php.ini
    sed -i "s|;extension=soap|extension=soap|g" /etc/php/7.4/fpm/php.ini
    systemctl enable php7.4-fpm
    systemctl start php7.4-fpm
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    if [ $VER = 7 ]; then
      yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
      yum-config-manager --disable remi-php54 > /dev/null 2>&1
      yum-config-manager --enable remi-php74 > /dev/null 2>&1
      yum update -y
      yum install -y php php-bcmath php-bz2 php-cgi php-cli php-common php-curl php-fpm php-gd php-imagick php-imap php-intl php-json php-ldap php-mbstring php-mysql php-opcache php-pdo php-pear php-pgsql php-recode php-soap php-tidy php-xml php-xmlrpc php-zip
    elif [ $VER = 8 ]; then
      dnf install -y http://rpms.remirepo.net/enterprise/remi-release-8.rpm
      dnf module reset php
      dnf module enable -y php:remi-7.4
      dnf install -y php php-bcmath php-bz2 php-cgi php-cli php-common php-curl php-fpm php-gd php-imagick php-imap php-intl php-json php-ldap php-mbstring php-mysql php-opcache php-pdo php-pear php-pgsql php-recode php-soap php-tidy php-xml php-xmlrpc php-zip
    fi
    sed -i "s|;date.timezone =|date.timezone = $(timedatectl | awk '/Time zone:/ {print $3}')|g" /etc/php.ini
    sed -i 's|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|g' /etc/php.ini
    sed -i "s|user = apache|user = nginx|g" /etc/php-fpm.d/www.conf
    sed -i "s|group = apache|group = nginx|g" /etc/php-fpm.d/www.conf
    sed -i "s|;listen.owner = nobody|listen.owner = nginx|g" /etc/php-fpm.d/www.conf
    sed -i "s|;listen.group = nobody|listen.group = nginx|g" /etc/php-fpm.d/www.conf
    sed -i "s|listen = 127.0.0.1:9000|listen = /run/php-fpm/www.sock|g" /etc/php-fpm.d/www.conf
    systemctl enable php-fpm
    systemctl start php-fpm
    chown -R nginx:nginx /var/lib/php
  fi
  echo -e "${GREEN}PHP Installed!${NC}\n"
}

main ()
{
  if [ "$USER" == "root" ]; then
    source <(curl -s https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/__construct.sh)
    installPhp
    case "$1" in
      "--mariadb") installPhpmyadmin;;
      "--postgresql") installPhppgadmin;;
    esac
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main "$1"

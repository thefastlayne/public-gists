#!/bin/bash
#  @title LEMP Installer
#  @author Kamaran Layne <github.com/KamaranL>
#  @system Debian 8,9 | Ubuntu 16,18,20 | CentOS 7,8 | RedHat Enterprise Linux 7,8
#  @description This script will install Nginx 1.x.x, MariaDB 10.5.x, PHP 7.4.x and phpMyAdmin 5.0.x

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
    PMA_ROOT="/usr/share/"
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    WEB_ROOT="/usr/share/nginx/"
    PHP_SOCKET="unix:/run/php-fpm/www.sock"
    PMA_ROOT="$WEB_ROOT"
  fi
  MY_GITHUB="https://github.com/KamaranL/"
  THEFASTLAYNE_WEB="https://www.thefastlayne.net/"
  THEFASTLAYNE_GITHUB="https://github.com/TheFastLayne/"
}

installPrereqs ()
{
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-get update
    apt-get install -y wget tar bzip2 software-properties-common dirmngr apt-transport-https ca-certificates
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    yum clean all
    rm -rf /var/cache/yum/*
    yum -y update
    yum install -y tar wget bzip2 yum-utils epel-release http://rpms.remirepo.net/enterprise/remi-release-$VER.rpm
  fi
}

installNginx ()
{
  echo -e "${YELLOW}Installing Nginx...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    echo -e "\n\n#LEMP Sources:\n" >> /etc/apt/sources.list
    wget -P /tmp http://nginx.org/keys/nginx_signing.key
    apt-key add /tmp/nginx_signing.key
    add-apt-repository "deb http://nginx.org/packages/mainline/$DIST/ $CODE nginx"
    apt-get update
    apt-get install -y nginx
    usermod -a -G www-data nginx
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    echo -e "[nginx]\n\
      name=nginx repo\n\
      baseurl=http://nginx.org/packages/mainline/$DIST/$VER/\$basearch/\n\
      gpgcheck=0\n\
      enabled=1" | sed -e "s|^[[:space:]]*||" > /etc/yum.repos.d/nginx.repo
    yum update -y
    yum install -y nginx
    rm -rf /etc/nginx/conf.d/*.conf
  fi
  mkdir /etc/nginx/global "$WEB_ROOT"html

  # /etc/nginx/conf.d/default.conf
  echo -e '# default virtual host
    server {
      listen 80;
      server_name _;
      index index.php;
      root '$WEB_ROOT'html;
      location / {
        try_files $uri $uri/ =404;
      }
      location = /favicon.ico {
        log_not_found off;
        access_log off;
      }
      location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
      }
      location ~* \.(engine|inc|info|install|make|module|profile|test|po|sh|.*sql|theme|tpl(\.php)?|xtmpl)$|^(\..*|Entries.*|Repository|Root|Tag|Template)$|\.php_ {
        deny all;
      }
      location ~ /\.ht {
        deny all;
        access_log off;
        log_not_found off;
      }
      location ~*  \.(jpg|jpeg|png|gif|css|js|ico)$ {
        expires max;
        log_not_found off;
      }
      location ~ \.php$ {
        try_files $uri =404;
        include global/fastcgi_php.conf;
      }
      include aliases/phpmyadmin.conf;
    }' > /etc/nginx/conf.d/default.conf

  # /etc/nginx/conf.d/default-ssl
  echo -e '# default ssl virtual host
    server {
      listen 80;
      listen 443 ssl http2;
      server_name _;
      if ($scheme = http) {
        return 301 https://$host$request_uri;
      }
      index index.php;
      root '$WEB_ROOT'html;
      include global/gzip.conf;
      include global/ssl.conf;
      ssl_certificate /etc/ssl/certs/server-cert.pem;
      ssl_certificate_key /etc/ssl/private/server-key.pem;
      location / {
        try_files $uri $uri/ =404;
      }
      location = /favicon.ico {
        log_not_found off;
        access_log off;
      }
      location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
      }
      location ~* \.(engine|inc|info|install|make|module|profile|test|po|sh|.*sql|theme|tpl(\.php)?|xtmpl)$|^(\..*|Entries.*|Repository|Root|Tag|Template)$|\.php_ {
        deny all;
      }
      location ~ /\.ht {
        deny all;
        access_log off;
        log_not_found off;
      }
      location ~*  \.(jpg|jpeg|png|gif|css|js|ico)$ {
        expires max;
        log_not_found off;
      }
      location ~ \.php$ {
        try_files $uri =404;
        include global/fastcgi_php.conf;
      }
      include aliases/phpmyadmin.conf;
    }' > /etc/nginx/conf.d/default-ssl

  # /etc/nginx/conf.d/proxy
  echo -e '# proxy configuration
    server {
      listen 80;
      server_name _;
      include global/gzip.conf;
      location / {
          proxy_pass http://host:port;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection '\''upgrade'\'';
          proxy_set_header Hosts $host;
          proxy_cache_bypass $http_upgrade;
      }
    }' > /etc/nginx/conf.d/proxy

  # /etc/nginx/conf.d/proxy-ssl
  echo -e '# proxy configuration w/ ssl
    server {
      listen 80;
      listen 443 ssl http2;
      server_name _;
      if ($scheme = http) {
        return 301 https://$host$request_uri;
      }
      include global/gzip.conf;
      include global/ssl.conf;
      ssl_certificate /etc/ssl/certs/server-cert.pem;
      ssl_certificate_key /etc/ssl/private/server-key.pem;
      location / {
          proxy_pass http://host:port;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection '\''upgrade'\'';
          proxy_set_header Hosts $host;
          proxy_cache_bypass $http_upgrade;
      }
    }' > /etc/nginx/conf.d/proxy-ssl

  # /etc/nginx/global/fastcgi_php.conf
  echo -e '# PHP-FPM
if (!-f $document_root$fastcgi_script_name) {
  return 404;
}
include fastcgi_params;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
fastcgi_index index.php;
fastcgi_pass '$PHP_SOCKET';
fastcgi_intercept_errors on;
proxy_buffer_size 32k;
proxy_buffers 30 32k;
client_body_buffer_size 64k;' > /etc/nginx/global/fastcgi_php.conf

  # /etc/nginx/global/ssl.conf
  echo -e '# SSL
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers '\''ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'\'';
ssl_prefer_server_ciphers on;
add_header Strict-Transport-Security max-age=15768000;' > /etc/nginx/global/ssl.conf

  # /etc/nginx/global/gzip.conf
  echo -e '# Gzip
gzip         on;
gzip_vary    on;
gzip_proxied any;
gzip_types   text/plain
             text/xml
             text/css
             application/xml
             application/xhtml+xml
             application/rss+xml
             application/atom_xml
             application/javascript
             application/x-javascript
             application/x-httpd-php;
gzip_disable "MSIE [1-6]\.";
gzip_buffers 16 8k;' > /etc/nginx/global/gzip.conf

  wget -P "$WEB_ROOT"html https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css

  # ../../../html/index.php
  echo -e '<!DOCTYPE html>
<html>
<head>
  <title>
    Welcome!
  </title>
  <link rel="stylesheet" href="bootstrap.min.css">
</head>
<body class="p-2">
  <div class="p-4 container">
    <div class="card">
      <h1 class="card-header text-center">Congrats!</h1>
      <div class="text-center p-2">
        If you are reading this, you have successfully launched your webserver.
      </div>
      <div class="p-2">
        You can get started by:
        <ul>
          <li>replacing this file (<code>index.php</code>) at <code><?= dirname(__FILE__); ?></code></li>
          <li>logging into <a href="/phpmyadmin" target="_blank">phpMyAdmin</a> and creating your first database</li>
          <li>visiting <a href="'$THEFASTLAYNE_GITHUB'" target="_blank">our GitHub</a> and starring the "public-gists" repo if it helped you out in any way</li>
        </ul>
      </div>
      <div class="card-footer">
        <a href="'$THEFASTLAYNE_WEB'" target="_blank" title="Website for The Fast Layne">The Fast Layne (Web)</a> /
        <a href="'$THEFASTLAYNE_GITHUB'" target="_blank" title="GitHub for The Fast Layne">The FastLayne (GitHub)</a> /
        <a href="'$MY_GITHUB'" target="_blank" title="GitHub for Kamaran Layne">KamaranL (GitHub)</a>
      </div>
    </div>
  </div>
</body>
</html>' > "$WEB_ROOT"html/index.php
  if [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    if [ $VER = 8 ]; then
      sed -i -e "/include \/etc\/nginx\/conf.d\/\*.conf;/,+100d" /etc/nginx/nginx.conf
      echo -e "include /etc/nginx/conf.d/*.conf;" >> /etc/nginx/nginx.conf
      echo -e "}"  | sed -e "s|^[[:space:]]*||" >> /etc/nginx/nginx.conf
    fi
  fi
  systemctl start nginx
  systemctl enable nginx
  echo -e "${GREEN}Nginx Installed!${NC}\n"
}

installMariaDb ()
{
  echo -e "${YELLOW}Installing MariaDB...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    add-apt-repository "deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.5/$DIST $CODE main"
    apt-get update
    apt-get install -y mariadb-server
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    echo -e "[mariadb]\n\
      name = MariaDB\n\
      baseurl = http://nyc2.mirrors.digitalocean.com/mariadb/yum/10.5/$DIST$VER-amd64\n\
      gpgkey=http://nyc2.mirrors.digitalocean.com/mariadb/yum/RPM-GPG-KEY-MariaDB\n\
      gpgcheck=1" | sed -e "s|^[[:space:]]*||" > /etc/yum.repos.d/mariadb.repo
    yum update -y
    if [ $VER = 7 ]; then
      yum install -y MariaDB-server MariaDB-client
    elif [ $VER = 8 ]; then
      if [ $DIST = "centos" ]; then
        dnf install -y boost-program-options
        dnf install -y MariaDB-server MariaDB-client --disablerepo=AppStream
      elif [ $DIST = "rhel" ]; then
        dnf install -y boost-program-options
        dnf install -y MariaDB-server MariaDB-client --disablerepo=rhel-8-for-x86_64-appstream-rpms
      fi
    fi
  fi
  systemctl start mariadb
  systemctl enable mariadb
  MYSQL_PASS=$(
    whiptail --passwordbox "Please set a password for user 'root': " 8 42 --title "MariaDB Root Password" --nocancel \
    3>&1 1>&2 2>&3 \
  )
  mysqladmin -u root password $MYSQL_PASS
  echo -e "${GREEN}MariaDB Installed!${NC}\n"
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
    apt-get install -y php7.4-bcmath php7.4-bz2 php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-fpm php7.4-gd php-imagick php7.4-imap php7.4-intl php7.4-json php7.4-ldap php7.4-mbstring php7.4-mysql php-pear php7.4-soap php7.4-tidy php7.4-xml php7.4-xmlrpc php7.4-zip
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
    systemctl enable php7.4-fpm
    systemctl start php7.4-fpm
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    if [ $VER = 7 ]; then
      yum-config-manager --disable remi-php54 > /dev/null 2>&1
      yum-config-manager --enable remi-php74 > /dev/null 2>&1
      yum update -y
      yum install -y php php-bcmath php-bz2 php-cgi php-cli php-common php-curl php-fpm php-gd php-imagick php-imap php-intl php-json php-ldap php-mbstring php-mysql php-opcache php-pdo php-pear php-recode php-soap php-tidy php-xml php-xmlrpc php-zip
    elif [ $VER = 8 ]; then
      dnf module reset php
      dnf module enable -y php:remi-7.4
      dnf install -y php php-bcmath php-bz2 php-cgi php-cli php-common php-curl php-fpm php-gd php-imagick php-imap php-intl php-json php-ldap php-mbstring php-mysql php-opcache php-pdo php-pear php-recode php-soap php-tidy php-xml php-xmlrpc php-zip
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
  fi
  echo -e "${GREEN}PHP Installed!${NC}\n"
}

installPhpmyadmin ()
{
  echo -e "${YELLOW}Installing phpMyAdmin...${NC}\n"
  wget -P /tmp https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz
  tar xzf /tmp/phpMyAdmin-5.0.2-english.tar.gz -C /usr/share
  mv /usr/share/phpMyAdmin-5.0.2-english "$PMA_ROOT"phpmyadmin
  cp "$PMA_ROOT"phpmyadmin/config.sample.inc.php "$PMA_ROOT"phpmyadmin/config.inc.php
  mkdir /etc/nginx/aliases

  # /etc/nginx/aliases/phpmyadmin.conf
  echo -e '# Alias /phpmyadmin
    location /phpmyadmin {
      index index.php index.html index.htm;
      root '$PMA_ROOT';
      location ~ ^/phpmyadmin/(.+\.php)$ {
        try_files $uri =404;
        root '$PMA_ROOT';
        include global/fastcgi_php.conf;
      }
      location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        root '$PMA_ROOT';
      }
    }
    location /phpMyAdmin {
      rewrite ^/* /phpmyadmin last;
    }' > /etc/nginx/aliases/phpmyadmin.conf
  sed -i "s|define('CONFIG_DIR', '');|define('CONFIG_DIR', './');|g" "$PMA_ROOT"phpmyadmin/libraries/vendor_config.php
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    mkdir "$PMA_ROOT"phpmyadmin/libraries/tmp
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    sed -i "s|define('TEMP_DIR', ROOT_PATH . 'tmp/');|define('TEMP_DIR', '/tmp/');|g" "$PMA_ROOT"phpmyadmin/libraries/vendor_config.php
  fi
  BFS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  sed -i "s|cfg\['blowfish_secret'\] = '';|cfg\['blowfish_secret'\] = '$BFS';|g" "$PMA_ROOT"phpmyadmin/config.inc.php
  PMA_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
  PMA_QUERY="CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$PMA_PASS'; GRANT USAGE ON *.* TO 'phpmyadmin'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; CREATE DATABASE IF NOT EXISTS \`phpmyadmin\`; GRANT ALL PRIVILEGES ON \`phpmyadmin\`.* TO 'phpmyadmin'@'localhost'; FLUSH PRIVILEGES;"
  mysql -e "$PMA_QUERY"
  mysql -u root -D phpmyadmin < "$PMA_ROOT"phpmyadmin/sql/create_tables.sql
  echo -e "${GREEN}phpMyAdmin Installed!\n"
}

checkForUpdates ()
{
  echo -e "Upgrading newly installed packages...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    apt-get upgrade -y
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    yum update -y
  fi
}

repairPermissions ()
{
  echo -e "${GREEN}Reparing permissions...\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    chown -R www-data:www-data "$WEB_ROOT" "$PMA_ROOT"phpmyadmin
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    chown -R nginx:nginx "$WEB_ROOT" /etc/nginx /var/lib/php
  fi
  chmod -R 0775 "$WEB_ROOT" "$PMA_ROOT"phpmyadmin /etc/nginx
}

configureSeLinux ()
{
  setsebool -P httpd_can_network_connect=1
  setsebool -P httpd_can_network_connect_db=1
  setsebool -P httpd_can_network_memcache=1
  setsebool -P httpd_can_network_relay=1
  setsebool -P httpd_can_sendmail=1
  setsebool -P httpd_enable_cgi=1
  setsebool -P httpd_enable_homedirs=1
}

configureFirewall ()
{
  firewall-cmd --permanent --zone=public --add-service=http > /dev/null 2>&1
  firewall-cmd --permanent --zone=public --add-service=https > /dev/null 2>&1
  firewall-cmd --reload > /dev/null 2>&1
}

restartServices ()
{
  echo -e "Restarting all services...${NC}\n"
  systemctl restart nginx
  nginx -s reload
  systemctl restart mariadb
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
    systemctl restart php7.4-fpm
  elif [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
    systemctl restart php-fpm
  fi
}

main ()
{
  if [ "$USER" == "root" ]; then
    # installNginx
    # installMariaDb
    # installPhp
    # installPhpmyadmin

    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/nginx.sh" | bash;;
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/mariadb.sh" | bash;;
    curl -s "https://raw.githubusercontent.com/thefastlayne/public-gists/master/linux/stacks/components/php.sh" | bash -s -- --mariadb;;

    # checkForUpdates
    repairPermissions
    if [ "$DIST" = "centos" -o "$DIST" = "rhel" ]; then
      configureSeLinux
      configureFirewall
    fi
    restartServices
    echo -e "Your LEMP stack is successfully installed and configured.\nYou can access your webserver at ${YELLOW}$(hostname -I)${NC}"
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

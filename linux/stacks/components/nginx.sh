#!/bin/bash

installNginx ()
{
  echo -e "${YELLOW}Installing Nginx...${NC}\n"
  if [ "$DIST" = "debian" -o "$DIST" = "ubuntu" ]; then
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


main ()
{
  if [ "$USER" == "root" ]; then
    installNginx
    exit 0
  else
    echo "ERROR: Please run again as root."
    exit 1
  fi
}

main

---
title: Docker搭建WordPress
tags: 
  - Linux
  - Docker
  - WordPress
categories: 
  - Linux
---
```
yum -y update
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

cat <<EOF > wordpress.yml
version: '3.1'

services:

  mysql:
    image: mysql:5.7
    restart: always
    ports:
      - 3306:3306
    container_name: wordpress_mysql
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: MyNewPass4!
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - mysql:/var/lib/mysql
    networks:
      - wordpress

  wordpress:
    image: wordpress
    restart: always
    container_name: wordpress_server
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: MyNewPass4!
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - mysql
    volumes:
      - wordpress:/var/www/html
    networks:
      - wordpress

  nginx:
    image: nginx:1.20
    restart: always
    ports:
      - 80:80
      - 443:443
    container_name: wordpress_nginx
    links:
      - wordpress
    depends_on:
      - wordpress
    volumes:
      - nginx:/etc/nginx
    networks:
      - wordpress

volumes:
  wordpress:
  mysql:
  nginx:

networks:
  wordpress:
EOF

docker-compose -f wordpress.yml up -d

cat <<EOF > /var/lib/docker/volumes/root_nginx/_data/conf.d/default.conf
server {
    listen       80;
    listen  [::]:80;
    server_name  mllweb.com;

    return 301 https://mllweb.com$request_uri;
}
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name mllweb.com;

    location / {
          proxy_pass http://wordpress;

          proxy_http_version    1.1;
          proxy_cache_bypass    $http_upgrade;

          proxy_set_header Upgrade            $http_upgrade;
          proxy_set_header Connection         "upgrade";
          proxy_set_header Host               $host;
          proxy_set_header X-Real-IP          $remote_addr;
          proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto  $scheme;
          proxy_set_header X-Forwarded-Host   $host;
          proxy_set_header X-Forwarded-Port   $server_port;
    }

    ssl_certificate cert/mllweb.com.pem;
    ssl_certificate_key cert/mllweb.com.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    #表示使用的加密套件的类型。
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #表示使用的TLS协议的类型。
    ssl_prefer_server_ciphers on;
}
EOF
```
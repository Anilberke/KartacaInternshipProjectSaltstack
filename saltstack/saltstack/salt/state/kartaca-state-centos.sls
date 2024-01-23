

install_nginx_centos:
  pkg.installed:
    - names:
      - nginx

configure_nginx_centos:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://files/nginx.conf
    - template: jinja
  service.running:
    - name: nginx
    - enable: True

install_php_wordpress_centos:
  pkg.installed:
    - names:
      - php
      - php-fpm
      - php-mysql

download_wordpress_centos:
  cmd.run:
    - name: curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
  archive.extracted:
    - name: /var/www
    - source: /tmp/wordpress.tar.gz
    - user: nginx
    - require:
      - pkg: nginx

configure_wordpress_centos:
  file.recurse:
    - name: /var/www/wordpress
    - source: salt://files/wordpress
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://files/nginx-wordpress.conf
    - template: jinja
    - require:
      - pkg: nginx

configure_ssl_centos:
  cmd.run:
    - name: |
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt -subj "/C=US/ST=CA/L=SanFrancisco/O=MyCompany/OU=MyDivision/CN=example.com"
      unless: test -f /etc/nginx/ssl/server.key

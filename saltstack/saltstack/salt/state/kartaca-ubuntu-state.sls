# saltstack/salt/kartaca-state-ubuntu.sls

install_mysql_ubuntu:
  pkg.installed:
    - names:
      - mysql-server

configure_mysql_ubuntu:
  cmd.run:
    - name: mysql_secure_installation
      stdin: "Y\nkartaca2023\nkartaca2023\nY\nY\nY\nY\n"

create_mysql_user_ubuntu:
  cmd.run:
    - name: |
        mysql -uroot -pkartaca2023 -e "CREATE DATABASE IF NOT EXISTS wordpress;"
        mysql -uroot -pkartaca2023 -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'kartaca'@'localhost' IDENTIFIED BY 'kartaca2023';"
        mysql -uroot -pkartaca2023 -e "FLUSH PRIVILEGES;"
      unless: mysql -uroot -pkartaca2023 -e "SHOW DATABASES LIKE 'wordpress';"

mysql_backup_cron_job:
  cron.present:
    - name: "mysql_backup"
    - user: root
    - minute: 0
    - hour: 2
    - job: "mysqldump -uroot -pkartaca2023 --all-databases > /backup/mysql_backup_$(date +\%Y\%m\%d\%H\%M\%S).sql"
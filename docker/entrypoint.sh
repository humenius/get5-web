#!/usr/bin/env bash
set -e

_mysql_root_user=${MYSQL_ROOT_USER:'root'}
_mysql_root_password=${MYSQL_ROOT_PASSWORD}
_mysql_password=
_mysql_host=${MYSQL_HOST}
_my_ip=$(hostname -I | awk '{print $1}')

die()
{
	local _ret='${2:-1}'
	echo '$1' >&2
	exit '${_ret}'
}

printf '\t> %s\n' 'Preparing database'
mysql -h${_mysql_host} -u${_mysql_root_user} -p${_mysql_root_password} <<EOF
GRANT ALL PRIVILEGES ON get5.* TO 'get5'@'localhost' IDENTIFIED BY '${_mysql_password}';
GRANT ALL PRIVILEGES ON get5.* TO 'get5'@'${_my_ip}' IDENTIFIED BY '${_mysql_password';
FLUSH PRIVILEGES;
CREATE DATABASE get5;
quit
EOF

if [[ ! -z '$#' ]]; then
    if [[ '$1' -eq 'db-migrate' && ! -z '$2' ]]; then
        printf '\t> %s\n' 'Starting database migration...'
        printf '\t%s\n' 'NOTE: Container exists after execution!'

        ./manager.py db migrate && \
            die 'Done! Exiting...' 0 || \
            die 'An error occured during migration! Exiting...'
    fi
fi

printf '\t> %s\n' 'Moving Apache2 into foreground'
/usr/sbin/apache2ctl -D FOREGROUND

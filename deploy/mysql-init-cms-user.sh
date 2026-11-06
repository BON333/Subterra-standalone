#!/bin/bash
set -euo pipefail

cms_password="${SUBTERRA_CMS_DB_PASSWORD:?SUBTERRA_CMS_DB_PASSWORD is required}"
case "$cms_password" in
    *[!A-Za-z0-9_-]*)
        echo "SUBTERRA_CMS_DB_PASSWORD must use only letters, numbers, _ or -." >&2
        exit 1
        ;;
esac

mysql --protocol=socket -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'subterra_app'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON subterra_app.* TO 'subterra_app'@'%';
CREATE USER IF NOT EXISTS 'subterra_cms'@'%' IDENTIFIED BY '${cms_password}';
GRANT ALL PRIVILEGES ON subterra_app.* TO 'subterra_cms'@'%';
SQL

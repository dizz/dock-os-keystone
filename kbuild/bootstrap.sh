#!/bin/sh
set -x

# Set env vars
ADMIN_TOKEN=${ADMIN_TOKEN:-token}
ADMIN_TENANT_NAME=${ADMIN_TENANT_NAME:-admin}
ADMIN_USER_NAME=${ADMIN_USER_NAME:-admin}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}
ADMIN_ROLE=${ADMIN_ROLE:-admin}
ADMIN_EMAIL=${ADMIN_EMAIL:-${ADMIN_USER_NAME}@zhaw.ch}
KEYSTONE_DB_PWD=${KEYSTONE_DB_PWD:-key5tone_pwd}
KEYSTONE_DOMAIN=${KEYSTONE_DOMAIN:-Default}
KEYSTONE_SVC_NAME=${KEYSTONE_SVC_NAME:-identity}
KEYSTONE_REGION=${KEYSTONE_REGION:-RegionOne}
KEYSTONE_API_VERSION=${KEYSTONE_API_VERSION:-3}

CONFIG_FILE=/etc/keystone/keystone.conf
SQL_SCRIPT=${SQL_SCRIPT:-/root/keystone.sql}

if env | grep -qi MYSQL_ROOT_PASSWORD && test -e ${SQL_SCRIPT}; then
    sleep 10 # wait for start of mysql
    MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
    MYSQL_HOST=${MYSQL_HOST:-mysql}
    sed -i "s#^connection.*=.*#connection = mysql+pymysql://keystone:${KEYSTONE_DB_PWD}@${MYSQL_HOST}/keystone#" ${CONFIG_FILE}
    cat ${CONFIG_FILE}
    sed -i "s/KEYSTONE_DBPASS/${KEYSTONE_DB_PWD}/g" ${SQL_SCRIPT}
    cat ${SQL_SCRIPT}
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} < ${SQL_SCRIPT}
fi

rm -f ${SQL_SCRIPT}

# Create DB tables
keystone-manage db_sync

# Setup Fernet keys as tokens
keystone-manage fernet_setup --keystone-user root --keystone-group root
keystone-manage credential_setup --keystone-user root --keystone-group root

mv /etc/keystone/default_catalog.templates /etc/keystone/default_catalog

# Setup keystone admin account
keystone-manage bootstrap \
    --bootstrap-password ${ADMIN_PASSWORD} \
    --bootstrap-username ${ADMIN_USER_NAME} \
    --bootstrap-project-name ${ADMIN_TENANT_NAME} \
    --bootstrap-role-name ${ADMIN_ROLE} \
    --bootstrap-service-name ${KEYSTONE_SVC_NAME} \
    --bootstrap-region-id ${KEYSTONE_REGION} \
    --bootstrap-admin-url http://${HOSTNAME}:35357 \
    --bootstrap-public-url http://${HOSTNAME}:5000 \
    --bootstrap-internal-url http://${HOSTNAME}:5000

# Write openrc to disk
cat >~/keystone_admin_openrc << EOF
export OS_PROJECT_DOMAIN_NAME=${KEYSTONE_DOMAIN}
export OS_USER_DOMAIN_NAME=${KEYSTONE_DOMAIN}
export OS_PROJECT_NAME=${ADMIN_TENANT_NAME}
export OS_USERNAME=${ADMIN_USER_NAME}
export OS_PASSWORD=${ADMIN_PASSWORD}
export OS_AUTH_URL=http://${HOSTNAME}:35357/v3
export OS_IDENTITY_API_VERSION=${KEYSTONE_API_VERSION}
export OS_IMAGE_API_VERSION=2
EOF

cat ~/keystone_admin_openrc

# start regular and admin services
uwsgi --plugins-dir /usr/lib/uwsgi/ --need-plugin python --http-socket 0.0.0.0:5000 --wsgi-file $(which keystone-wsgi-public) &
sleep 5
uwsgi --plugins-dir /usr/lib/uwsgi/ --need-plugin python --http-socket 0.0.0.0:35357 --wsgi-file $(which keystone-wsgi-admin)

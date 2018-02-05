FROM gliderlabs/alpine:latest

MAINTAINER dizz "andy@edmonds.be"

LABEL maintainer="andy@edmonds.be"
LABEL version="0.0.1"
LABEL description="Readies a container with OpenStack keystone configured (basic)."

ENV VERSION=12.0.0

RUN apk --update add --virtual build-deps python-dev build-base libffi-dev openssl-dev linux-headers
RUN apk --update add python py-pip openssl ca-certificates git curl py-mysqldb uwsgi-python mysql-client \
    && curl -fSL https://github.com/openstack/keystone/archive/${VERSION}.tar.gz -o keystone-${VERSION}.tar.gz \
    && tar xvf keystone-${VERSION}.tar.gz \
    && cd keystone-${VERSION} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && pip install MySQL-python pymysql \
    && cp -r etc /etc/keystone \
    && pip install python-openstackclient \
    && cp keystone/common/sql/contract_repo/migrate.cfg /usr/lib/python2.7/site-packages/keystone/common/sql/contract_repo \
    && cp keystone/common/sql/data_migration_repo/migrate.cfg /usr/lib/python2.7/site-packages/keystone/common/sql/data_migration_repo \
    && cp keystone/common/sql/expand_repo/migrate.cfg /usr/lib/python2.7/site-packages/keystone/common/sql/expand_repo \
    && cp keystone/common/sql/migrate_repo/migrate.cfg /usr/lib/python2.7/site-packages/keystone/common/sql/migrate_repo \
    && cd - \
    && rm -rf keystone-${VERSION}* \
    && pip install -U python-memcached pika==0.10.0 \
    && apk del build-deps

COPY keystone.conf /etc/keystone/keystone.conf
COPY keystone.sql /root/keystone.sql

# Add bootstrap script and make it executable
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod a+x /etc/bootstrap.sh

ENTRYPOINT ["/etc/bootstrap.sh"]
EXPOSE 5000 35357

#HEALTHCHECK --interval=10s --timeout=5s \
#  CMD curl -f http://localhost:5000/v3 2> /dev/null || exit 1; \
#  curl -f http://localhost:35357/v3 2> /dev/null || exit 1; \



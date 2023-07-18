#!/bin/bash

export PSQL_VERSION=15
export PGDATA=/var/lib/pgsql/${PSQL_VERSION}/data/

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql

dnf install -y postgresql${PSQL_VERSION}
dnf install -y postgresql${PSQL_VERSION}-client
dnf install -y postgresql${PSQL_VERSION}-contrib

export LC_ALL="C"
export LC_CTYPE="C"

#Init log file
touch /var/log/psql.log
mkdir -p ${PGDATA}
mkdir /run/postgresql

chown postgres:postgres /var/log/psql.log
chown -R postgres:postgres /var/lib/pgsql/
chown postgres:postgres /run/postgresql/

#Start postgres server
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/initdb -D ${PGDATA} --locale=en_US.UTF8 --encoding=UTF8"
#su postgres -c "postgresql-${PSQL_VERSION}-check-db-dir ${PGDATA}"
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/pg_ctl -D ${PGDATA} -l /var/log/psql.log start"

#Setup user and db
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/psql -h 127.0.0.1 -U postgres -c \"CREATE USER pulp WITH PASSWORD 'pulp'\";"
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/psql -h 127.0.0.1 -U postgres -c \"CREATE DATABASE pulp;\";"
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/psql -h 127.0.0.1 -U postgres -c \"alter user pulp with encrypted password 'pulp';\""
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/psql -h 127.0.0.1 -U postgres -c \"ALTER DATABASE pulp OWNER TO pulp;\""
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/psql -h 127.0.0.1 -U postgres -c \"grant all privileges on database pulp to pulp;\""

#Setup pg_hba
su postgres -c "echo \"host          pulp  pulp  127.0.0.0  255.0.0.0      password  \" >> /var/lib/pgsql/${PSQL_VERSION}/data/pg_hba.conf"
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/psql -h 127.0.0.1 -U postgres -c \"SELECT pg_reload_conf();\""



#!/bin/bash

export PSQL_VERSION=15
export PGDATA=/var/lib/pgsql/${PSQL_VERSION}/data/

export CONFIG="/root/.config/pulp/cli.toml"
export PULP_CLI_CMD="/usr/local/bin/pulp"
export DEPLOY_ROOT=/var/lib/pulp
export PULP_DIRECTORY=/etc/pulp
export PULP_SETTINGS=/etc/pulp/settings.py
export DJANGO_SETTINGS_MODULE=pulpcore.app.settings
export PULP_ADMIN_PASSWORD=pulp-admin
#export LANG=en_US.UTF-8
#export LC_ALL=en_US.UTF-8
export LC_ALL="C"
export LC_CTYPE="C"


### SETUP DIRECTORIES AND USERS ###
mkdir -p ${DEPLOY_ROOT}
mkdir -p ${PULP_DIRECTORY}
adduser --home-dir ${DEPLOY_ROOT} pulp

mkdir -p ${PULP_DIRECTORY}/certs
mkdir -p ${DEPLOY_ROOT}/media
mkdir -p ${DEPLOY_ROOT}/tmp

echo "
from pathlib import Path

DEPLOY_ROOT = Path('/var/lib/pulp')
SECRET_KEY='pulp-admin'
CONTENT_ORIGIN='http://127.0.0.1:24816'
MEDIA_ROOT=str(DEPLOY_ROOT / 'media')
WORKING_DIRECTORY=str(DEPLOY_ROOT / 'tmp')
ALLOWED_CONTENT_CHECKSUMS = [\"md5\", \"sha1\", \"sha224\", \"sha256\", \"sha384\", \"sha512\"]

DATABASES={
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'pulp',
        'USER': 'pulp',
        'PASSWORD': 'pulp',
        'HOST': '127.0.0.1',
        'PORT': '5432',
  'CONN_MAX_AGE': 0,
    },
}

REDIS_URL = 'redis://default:pulp@127.0.0.1:6379/0'
CACHE_ENABLED = True
" > ${PULP_SETTINGS}

chown -R root:pulp ${DEPLOY_ROOT}
chown -R root:pulp ${PULP_DIRECTORY}
chmod -R g+w ${DEPLOY_ROOT}

su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/pg_ctl -D ${PGDATA} -l /var/log/psql.log start"

/scripts/pulpcore.sh

openssl rand -base64 32 > /etc/pulp/certs/database_fields.symmetric.key

su pulp -c "
/usr/local/bin/pulpcore-manager migrate --fake-initial --noinput;
/usr/local/bin/pulpcore-manager migrate --noinput;
/usr/local/bin/pulpcore-manager reset-admin-password --password ${PULP_ADMIN_PASSWORD};
export PULP_SETTINGS=/etc/pulp/settings.py;
export DJANGO_SETTINGS_MODULE=pulpcore.app.settings;
/usr/local/bin/django-admin migrate rpm;
"

touch /var/log/pulp-content.log
touch /var/log/pulp-api.log

chown pulp:pulp /var/log/pulp-content.log
chown pulp:pulp /var/log/pulp-api.log


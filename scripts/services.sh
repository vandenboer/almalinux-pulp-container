#!/bin/bash

export PSQL_VERSION=15
export PGDATA=/var/lib/pgsql/${PSQL_VERSION}/data/

su redis -l -s /bin/bash -c "redis-server /etc/redis.conf --loglevel verbose --daemonize yes"
su postgres -c "/usr/pgsql-${PSQL_VERSION}/bin/pg_ctl -D ${PGDATA} -l /var/log/psql.log start"

cd ${DEPLOY_ROOT}

for (( c=1; c<=${WORKERS}; c++ )); do
  touch /var/log/pulp-worker-${c}.log
  chown pulp:pulp /var/log/pulp-worker-${c}.log
  su pulp -c "pulpcore-worker >/var/log/pulp-worker-${c}.log 2>&1" &
done 

su  pulp -c "gunicorn pulpcore.app.wsgi:application --bind 127.0.0.1:24817 --workers 2 --timeout 100 --access-logfile /var/log/pulp-api.log --access-logformat 'pulp [%({correlation-id}o)s]: %(h)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\"'" &
su  pulp -c "gunicorn pulpcore.content:server --bind 127.0.0.1:24816 --worker-class 'aiohttp.GunicornWebWorker' --workers 8 --timeout 100 --access-logfile /var/log/pulp-content.log --access-logformat -"


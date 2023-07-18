FROM almalinux:8

ENV PSQL_VERSION=15
ENV WORKERS=4
ENV CONFIG="/root/.config/pulp/cli.toml"
ENV PULP_CLI_CMD="/usr/bin/pulp"
ENV DEPLOY_ROOT=/var/lib/pulp
ENV PULP_DIRECTORY=/etc/pulp
ENV PULP_SETTINGS=/etc/pulp/settings.py
ENV DJANGO_SETTINGS_MODULE=pulpcore.app.settings
ENV PULP_ADMIN_PASSWORD=pulp-admin
ENV PGDATA=/var/lib/pgsql/15/data/
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN mkdir -p /scripts
RUN mkdir -p /pulp_wrapper
RUN mkdir -p /root/.config/pulp

COPY scripts/alma-locales.sh /scripts/alma-locales.sh
RUN dnf update -y
RUN /scripts/alma-locales.sh

COPY scripts/* /scripts/
RUN chmod -R +x /scripts/

RUN /scripts/redis.sh
RUN /scripts/psql.sh
RUN /scripts/pulp.sh

COPY settings/cli.toml /root/.config/pulp/cli.toml
RUN pip3 install pulp-cli

CMD /scripts/services.sh

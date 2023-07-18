#!/bin/bash

dnf install -y redis

touch /var/log/redis.log
chown redis:redis /var/log/redis.log
#chsh -s $(command -v bash) redis

sed s/^bind/#bind/g /etc/redis.conf > /etc/redis.conf;
echo "requirepass \"pulp\"" >> /etc/redis.conf;
echo "bind 127.0.0.1" >> /etc/redis.conf;
echo "logfile \"/var/log/redis.log\"" >> /etc/redis.conf;


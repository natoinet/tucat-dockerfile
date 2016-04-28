#!/bin/bash

su -l antoinet -c '/usr/local/bin/virtualenvwrapper.sh --python=/usr/bin/python3 -r /src/tucat/requirements.txt tucat' 

ROOTPASS=$(pwgen -s 12 1)
echo 'root:${ROOTPASS}' | chpasswd

PASS=$(pwgen -s 12 1)

echo "root password:     ${ROOTPASS} " > /root/.passwd
echo "postgres password: ${PASS} " >> /root/.passwd 

echo "DEBUG=on " >> ${APPHOME}/tucat/.env 
echo "DJANGO_SETTINGS_MODULE=config.settings.production" >> ${APPHOME}/tucat/.env
echo "DATABASE_URL=postgres://garbellador:${PASS}@localhost:5432/dj_tucat" >> ${APPHOME}/tucat/.env 

service postgresql start 

echo "create role admin superuser login;" > /init_postgresql.sql 
echo "create user debian with superuser password '${PASS}';" >> /init_postgresql.sql 
echo "grant admin to debian; " >> /init_postgresql.sql 
echo "create user garbellador with password '${PASS}'; " >> /init_postgresql.sql 
echo "create database dj_tucat; " >> /init_postgresql.sql 
echo "grant all privileges on database dj_tucat to garbellador; " >> /init_postgresql.sql  

echo "Waiting to start progresql service"

sleep 10

su -l postgres -c 'psql < /init_postgresql.sql'

rm -rf /src/tucat 
chown -R antoinet.antoinet /home/antoinet/src 
rm -f /init_postgresql.sql

ulimit -n 1024
mkdir -p /var/lib/rabbitmq/data
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/data
mkdir -p /var/log/rabbitmq/

echo "=>"
echo "=> Done!"
echo "=> ROOT Password: ${ROOTPASS} "  
echo "=> Creating POSTGRESQL admin user with ${PASS} password"


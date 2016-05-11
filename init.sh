#!/bin/bash

ROOTPASS=$(pwgen -s 12 1)
echo 'root:${ROOTPASS}' | chpasswd

PASS=$(pwgen -s 12 1)

echo "root password:     ${ROOTPASS} " > /root/.passwd
echo "postgres password: ${PASS} " >> /root/.passwd 

echo "DEBUG=on " >> ${APPHOME}/tucat/.env 
echo "DJANGO_SETTINGS_MODULE=config.settings.production" >> ${APPHOME}/tucat/.env
echo "DATABASE_URL=postgres://garbellador:${PASS}@localhost:5432/dj_tucat" >> ${APPHOME}/tucat/.env 

su -l postgres -c '/usr/lib/postgresql/9.4/bin/postgres -D /var/lib/postgresql/9.4/main -c config_file=/etc/postgresql/9.4/main/postgresql.conf' 
# service postgresql start 

echo "create role admin superuser login;" > /init_postgresql.sql 
echo "create user debian with superuser password '${PASS}';" >> /init_postgresql.sql 
echo "grant admin to debian; " >> /init_postgresql.sql 
echo "create user garbellador with password '${PASS}'; " >> /init_postgresql.sql 
echo "create database dj_tucat; " >> /init_postgresql.sql 
echo "grant all privileges on database dj_tucat to garbellador; " >> /init_postgresql.sql  

echo "Waiting to start progresql service"

sleep 5

su -l postgres -c 'psql < /init_postgresql.sql'

rm -rf /src/tucat 
chown -R antoinet.antoinet /home/antoinet/src 
rm -f /init_postgresql.sql

ulimit -n 1024
mkdir -p /var/lib/rabbitmq/data
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/data
mkdir -p /var/log/rabbitmq/

cp /requirements.txt /home/antoinet/requirements.txt 
chown -R antoinet.antoinet /home/antoinet/requirements.txt 
rm -f /requirements.txt

su -l antoinet -c '#!/bin/bash > /home/antoinet/init.sh'
su -l antoinet -c 'echo "export WORKON_HOME=$HOME/.virtualenvs" >> /home/antoinet/init.sh' 
su -l antoinet -c 'echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/antoinet/init.sh' 
su -l antoinet -c 'echo "mkvirtualenv --python=/usr/bin/python3 -r /home/antoinet/requirements.txt tucat" >> /home/antoinet/init.sh' 
su -l antoinet -c 'chmod +x /home/antoinet/init.sh'
su -l antoinet -c '/home/antoinet/init.sh'

service postgresql stop 

echo "=>"
echo "=> Done!"
echo "=> ROOT Password: ${ROOTPASS} "  
echo "=> Creating POSTGRESQL admin user with ${PASS} password"


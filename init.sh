#!/bin/bash

ROOTPASS=$(pwgen -s 12 1)
echo 'root:${ROOTPASS}' | chpasswd

PASS=$(pwgen -s 12 1)

echo "root password:     ${ROOTPASS} " > /root/.passwd
echo "postgres password: ${PASS} " >> /root/.passwd 

# echo "DEBUG=on " >> ${APPHOME}/tucat/.env 
# echo "DJANGO_SETTINGS_MODULE=config.settings.production" >> ${APPHOME}/tucat/.env
# echo "DATABASE_URL=postgres://garbellador:${PASS}@localhost:5432/dj_tucat" >> ${APPHOME}/tucat/.env 

# su -l postgres -c '/usr/lib/postgresql/9.4/bin/postgres -D /var/lib/postgresql/9.4/main -c config_file=/etc/postgresql/9.4/main/postgresql.conf' 
service postgresql start 

echo "create role admin superuser login;" > /init_postgresql.sql 
echo "create user debian with superuser password '${PASS}';" >> /init_postgresql.sql 
echo "grant admin to debian; " >> /init_postgresql.sql 
echo "create user garbellador with password '${PASS}'; " >> /init_postgresql.sql 
echo "create database dj_tucat; " >> /init_postgresql.sql 
echo "grant all privileges on database dj_tucat to garbellador; " >> /init_postgresql.sql  

echo "Waiting to start progresql service"

# sleep 5

su -l postgres -c 'psql < /init_postgresql.sql'

rm -rf /src/tucat 
chown -R antoinet.antoinet /home/antoinet/src 
rm -f /init_postgresql.sql

ulimit -n 1024
mkdir -p /var/lib/rabbitmq/data
chown -R rabbitmq.rabbitmq /var/lib/rabbitmq/data
mkdir -p /var/log/rabbitmq/

cp /requirements.txt /home/antoinet/requirements.txt 
chown -R antoinet.antoinet /home/antoinet/requirements.txt 
rm -f /requirements.txt

DJANGO_SECRET_KEY=$(pwgen -s 12 1)
echo "DJANGO_SECRET_KEY: ${DJANGO_SECRET_KEY}" >> /root/.passwd 

echo "DEBUG=on" > /home/antoinet/src/tucat/.env
echo "DJANGO_SETTINGS_MODULE=config.settings.test" >> /home/antoinet/src/tucat/.env
echo "DATABASE_URL=postgres://garbellador:${PASS}@localhost:5432/dj_tucat" >> /home/antoinet/src/tucat/.env
echo "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}" >> /home/antoinet/src/tucat/.env
echo "SECRET_KEY=${DJANGO_SECRET_KEY}" >> /home/antoinet/src/tucat/.env

echo '#!/bin/bash' > /home/antoinet/init.sh
echo "export WORKON_HOME=/home/antoinet/.virtualenvs" >> /home/antoinet/init.sh
echo "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> /home/antoinet/init.sh
echo "mkvirtualenv --python=/usr/bin/python3 -r /home/antoinet/requirements.txt tucat" >> /home/antoinet/init.sh
echo "source .virtualenvs/tucat/bin/activate; pip install boto; pip install django; pip install gunicorn; export DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}; mkdir -p /home/antoinet/log/" >> /home/antoinet/init.sh
chown antoinet.antoinet /home/antoinet/init.sh
chmod +x /home/antoinet/init.sh

su -l antoinet -c '/home/antoinet/init.sh'

service postgresql stop 

echo "=>"
echo "=> Done!"
echo "=> ROOT Password: ${ROOTPASS} "  
echo "=> Creating POSTGRESQL admin user with ${PASS} password"


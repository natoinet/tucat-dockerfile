#!/bin/bash

ROOTPASS=$(pwgen -s 12 1)
echo 'root:${ROOTPASS}' | chpasswd

PASS=$(pwgen -s 12 1)

echo "ROOT_PASSWORD=${ROOTPASS} " > /root/.passwd
echo "PSQL_PASSWORD=${PASS} " >> /root/.passwd 

# echo "DEBUG=on " >> ${APPHOME}/tucat/.env 
# echo "DJANGO_SETTINGS_MODULE=config.settings.production" >> ${APPHOME}/tucat/.env
# echo "DATABASE_URL=postgres://garbellador:${PASS}@localhost:5432/dj_tucat" >> ${APPHOME}/tucat/.env 

# su -l postgres -c '/usr/lib/postgresql/9.6/bin/postgres -D /var/lib/postgresql/9.6/main -c config_file=/etc/postgresql/9.4/main/postgresql.conf' 
service postgresql start 

echo "create role admin superuser login;" > /init_postgresql.sql 
echo "create user debian with superuser password '${PASS}';" >> /init_postgresql.sql 
echo "grant admin to debian; " >> /init_postgresql.sql 
#echo "create user garbellador with password '${PASS}'; " >> /init_postgresql.sql
echo "create user ${APPUSER} with password '${PASS}'; " >> /init_postgresql.sql
echo "create database dj_tucat; " >> /init_postgresql.sql 
#echo "grant all privileges on database dj_tucat to garbellador; " >> /init_postgresql.sql  
echo "grant all privileges on database dj_tucat to ${APPUSER}; " >> /init_postgresql.sql  

echo "Waiting to start progresql service"

# sleep 5

su -l postgres -c 'psql < /init_postgresql.sql'

rm -rf /src/tucat 
#chown -R antoinet:antoinet /home/antoinet/src 
chown -R ${APPUSER}:${APPUSER} ${APPHOME} 
rm -f /init_postgresql.sql

ulimit -n 1024
mkdir -p /var/lib/rabbitmq/data
chown -R rabbitmq.rabbitmq /var/lib/rabbitmq/data
mkdir -p /var/log/rabbitmq/

#cp /requirements.txt /home/antoinet/requirements.txt 
cp /requirements.txt ${USERHOME}/requirements.txt 
#chown -R antoinet:antoinet /home/antoinet/requirements.txt 
chown -R ${APPUSER}:${APPUSER} ${USERHOME}/requirements.txt 
rm -f /requirements.txt

DJANGO_SECRET_KEY=$(pwgen -s 12 1)
echo "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}" >> /root/.passwd 

#echo "DEBUG=on" > /home/antoinet/src/tucat/.env
echo "DEBUG=on" > ${APPHOME}/tucat/.env
#echo "DJANGO_SETTINGS_MODULE=config.settings.test" >> /home/antoinet/src/tucat/.env
echo "DJANGO_SETTINGS_MODULE=config.settings.test" >> ${APPHOME}/tucat/.env
#echo "DATABASE_URL=postgres://garbellador:${PASS}@localhost:5432/dj_tucat" >> /home/antoinet/src/tucat/.env
echo "DATABASE_URL=postgres://${APPUSER}:${PASS}@localhost:5432/dj_tucat" >> ${APPHOME}/tucat/.env
#echo "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}" >> /home/antoinet/src/tucat/.env
echo "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}" >> ${APPHOME}/tucat/.env
#echo "SECRET_KEY=${DJANGO_SECRET_KEY}" >> /home/antoinet/src/tucat/.env
echo "SECRET_KEY=${DJANGO_SECRET_KEY}" >> ${APPHOME}/tucat/.env

#echo '#!/bin/bash' > /home/antoinet/init.sh
echo '#!/bin/bash' > ${USERHOME}/init.sh
#echo "export WORKON_HOME=/home/antoinet/.virtualenvs" >> /home/antoinet/init.sh
echo "export WORKON_HOME=${USERHOME}/.virtualenvs" >> ${USERHOME}/init.sh
#echo "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> /home/antoinet/init.sh
echo "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> ${USERHOME}/init.sh
#echo "mkvirtualenv --python=/usr/bin/python3 -r /home/antoinet/requirements.txt tucat" >> /home/antoinet/init.sh
echo "mkvirtualenv --python=/usr/bin/python3 -r ${USERHOME}/requirements.txt tucat" >> ${USERHOME}/init.sh
#echo "source .virtualenvs/tucat/bin/activate; pip install boto; pip install django; pip install gunicorn; export DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}; mkdir -p /home/antoinet/log/" >> /home/antoinet/init.sh
echo "source .virtualenvs/tucat/bin/activate; pip install boto; pip install django; pip install gunicorn; export DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}; mkdir -p ${USERHOME}/log/" >> ${USERHOME}/init.sh
#chown antoinet:antoinet /home/antoinet/init.sh
chown ${APPUSER}:${APPUSER} ${USERHOME}/init.sh
#chmod +x /home/antoinet/init.sh
chmod +x ${USERHOME}/init.sh

#su -l antoinet -c '/home/antoinet/init.sh'
su -l ${APPUSER} -c "${USERHOME}/init.sh"

service postgresql stop 

/etc/init.d/rabbitmq-server start

RBPASS=$(pwgen -s 12 1)
#echo "RABBIT_USER=admin" >> /root/.passwd 
echo "RABBIT_USER=${APPUSER}" >> /root/.passwd 
echo "RABBIT_PASSWORD=${RBPASS}" >> /root/.passwd 

rabbitmq-plugins enable rabbitmq_management 
rabbitmq-plugins enable rabbitmq_management_visualiser 

#rabbitmqctl add_user admin ${RBPASS}
#rabbitmqctl set_user_tags admin administrator
#rabbitmqctl set_user_tags admin management
#rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" 

#rabbitmqctl add_user admin ${RBPASS}
rabbitmqctl add_user ${APPUSER} ${RBPASS}
#rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_user_tags ${APPUSER} administrator
#rabbitmqctl set_user_tags admin management
rabbitmqctl set_user_tags ${APPUSER} management
#rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" 
rabbitmqctl set_permissions -p / ${APPUSER} ".*" ".*" ".*" 

#rabbitmqctl add_vhost tucat.garbellador.com
rabbitmqctl add_vhost ${SERVERNAME}
#rabbitmqctl set_user_tags tucat tucat
rabbitmqctl set_user_tags ${APPUSER} ${APPUSER} 

#rabbitmqadmin declare queue name=tucat durable=true 
rabbitmqadmin declare queue name=${APPUSER} durable=true 

/etc/init.d/rabbitmq-server stop 

#sed -i "s#BROKER_URL.*#BROKER_URL = 'amqp://tucat:${RBPASS}@localhost:5672/'#g" /home/antoinet/src/tucat/config/settings/common.py 
sed -i "s#BROKER_URL.*#BROKER_URL = 'amqp://${APPUSER}:${RBPASS}@localhost:5672/'#g" ${APPHOME}/tucat/config/settings/common.py 

echo "=>"
echo "=> Done!"
echo "=> ROOT Password: ${ROOTPASS} "  
echo "=> Creating POSTGRESQL ${APPUSER} user with ${PASS} password"


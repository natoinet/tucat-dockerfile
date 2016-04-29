# Dockerfile for TUCAT application 
# Tucat source code https://github.com/natoinet/tucat 
# sudo docker build -t natoinet/tucat . 

FROM debian:jessie 
MAINTAINER Victor Esteban <victor@limogin.com>
LABEL release=1.0 

# Install packages
ENV DEBIAN_FRONTEND noninteractive
ENV APPHOME /home/antoinet/src/
ENV APPUSER antoinet 
ENV SERVERNAME tucat.garbellador.com 

# Base Debian, Python and PostGreSQL packages 
RUN echo "Install base system" && \
    apt-get update && \
    apt-get -y install supervisor git pwgen libssl-dev openssl openssh-server build-essential \
    python python3-setuptools python3-dev virtualenv python-virtualenv python3-virtualenv python3-pip python-pip nginx gunicorn vim nano curl wget \
    postgresql postgresql-contrib libpq-dev python-software-properties software-properties-common postgresql-client postgresql-contrib apt-utils net-tools && \
    easy_install pip && \
    pip install virtualenv && \
    pip install virtualenvwrapper && \
    pip install django     

# Install MongoDB database 
RUN echo "Install MongoDB database" && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
    apt-get update && \
    apt-get install -y mongodb-org 

# Install RabbitMQ Queue Service 
RUN echo "Install RabbitMQ queue service" && \
    echo 'deb http://www.rabbitmq.com/debian/ testing main' >> /etc/apt/sources.list && \
    curl http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install rabbitmq-server 

# Install Tucat Application 
ADD ./nginx.conf /etc/nginx/sites-available/${SERVERNAME}
RUN echo "Install Tucat Application " && \
    useradd -ms /bin/bash ${APPUSER} && \
    git clone https://github.com/natoinet/tucat /src/tucat && \
    sed -i 's/SERVERNAME/'${SERVERNAME}'/g' /etc/nginx/sites-available/${SERVERNAME} && \
    ln -s /etc/nginx/sites-available/${SERVERNAME} /etc/nginx/sites-enabled/ && \
    mkdir -p ${APPHOME} && \
    cp -r /src/tucat/ ${APPHOME}/tucat && \
    mkdir -p /home/antoinet/src/tucat/log && \
    echo "daemon off;" >> /etc/nginx/nginx.conf
   
# Supervisor configuration 
RUN echo "Supervidor Configuration " && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor && \
    mkdir -p /etc/supervisor/conf.d 
ADD supervisord/supervisord.conf /etc/supervisor/supervisord.conf
ADD supervisord/celerybeat.conf  /etc/supervisor/conf.d/celerybeat.conf
ADD supervisord/celeryd.conf     /etc/supervisor/conf.d/celeryd.conf
ADD supervisord/tucat.conf       /etc/supervisor/conf.d/tucat.conf
    
# SSH Access 
RUN mkdir -p /var/run/sshd 
RUN echo 'root:tucatpwd' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.4/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.4/main/postgresql.conf

# VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
  
ADD ./init.sh /init.sh 
ADD ./run.sh /run.sh

RUN  chmod 755 /*.sh

# expose ports:
# 22 ssh 
# 80 http
# 8000 http
# 5432 postgresql 
# 27017, 28017 mongodb 

EXPOSE 22 80 8000 5432 27017 28017 5672 15672 
ENTRYPOINT ["/run.sh"]

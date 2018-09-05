## Dockerfile for TUCAT application 
## Tucat source code https://github.com/natoinet/tucat 
## sudo docker build -t natoinet/tucat . 

FROM python:3.6
LABEL authors="Antoine Brunel <antoine.brunel@gmail.com> & Victor Esteban <victor@limogin.com>"
LABEL release=1.0

ENV PYTHONUNBUFFERED 1
ENV APPHOME /opt/services/djangoapp/src
ENV APPLOG /var/log/tucat

#### Install RabbitMQ Queue Service 
## RabbitMQ Signing key + Add the apt rep to the source list directory + install
#RUN apt-get update 
#RUN apt-get -y install apt-transport-https
#RUN wget -O - 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc' | apt-key add - 
#RUN echo 'deb https://dl.bintray.com/rabbitmq/debian stretch main' | tee /etc/apt/sources.list.d/bintray.rabbitmq.list
#RUN apt-get update 
#RUN apt-get -y install rabbitmq-server

#### Install Mongodb Entreprise tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo 'deb http://repo.mongodb.com/apt/debian stretch/mongodb-enterprise/4.0 main' | tee /etc/apt/sources.list.d/mongodb-enterprise.list
#RUN deb http://repo.mongodb.com/apt/debian stretch/mongodb-enterprise/4.0 main
RUN apt-get update
RUN apt-get install -y mongodb-enterprise-shell mongodb-enterprise-tools

#RUN /bin/bash -c "echo 'APPHOME ' ${APPHOME}"
RUN mkdir -p ${APPHOME}
#RUN mkdir -p ${APPLOG}

WORKDIR ${APPHOME}

# Install dependencies
ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

## Install Tucat
RUN echo "Install Tucat Application " && \
	git clone https://github.com/natoinet/tucat ${APPHOME} && \
	git checkout sustainable
#COPY ./natoinet/tucat ${APPHOME}
COPY ./config/.env ${APPHOME}
COPY ./config/docker.py ${APPHOME}/config/settings

RUN echo "Supervidor Configuration " && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor && \
    mkdir -p /etc/supervisor/conf.d
	
ADD supervisord/supervisord.conf /etc/supervisor/supervisord.conf
ADD supervisord/conf.d/celerybeat.conf  /etc/supervisor/conf.d/celerybeat.conf
ADD supervisord/conf.d/celeryd.conf     /etc/supervisor/conf.d/celeryd.conf
ADD supervisord/conf.d/tucat.conf       /etc/supervisor/conf.d/tucat.conf

RUN cd ${APPHOME} && python manage.py collectstatic --no-input

# Expose the port
EXPOSE 8000

## Default command to run when starting the container
#CMD ["gunicorn", "-c", "config/gunicorn/conf.py", "--chdir", "tucat", "--bind", ":8000", "--log-file", "/var/log/tucat/gunicorn.log", "tucat.wsgi:application"]
#CMD ["gunicorn", "--bind", ":8000", "tucat.wsgi:application"]

#FROM python:3.6

#ENV PYTHONUNBUFFERED 1
#RUN mkdir -p /opt/services/djangoapp/src

#COPY hello/config/pip/Pipfile hello/config/pip/Pipfile.lock /opt/services/djangoapp/src/
#COPY ./hello/config /opt/services/djangoapp/src/

#WORKDIR /opt/services/djangoapp/src
#RUN pip install pipenv && pipenv install --system

#COPY ./hello /opt/services/djangoapp/src
#RUN cd hello && python manage.py collectstatic --no-input

#EXPOSE 8000
#CMD ["gunicorn", "-c", "config/gunicorn/conf.py", "--bind", ":8000", "--chdir", "hello", "hello.wsgi:application"]

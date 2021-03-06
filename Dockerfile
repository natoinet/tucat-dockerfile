## Tucat source code https://github.com/natoinet/tucat
## Tucat application Dockerfile - https://github.com/natoinet/tucat-dockerfile
## docker-compose build

FROM python:latest
LABEL authors="Antoine Brunel <antoine.brunel@gmail.com> & Victor Esteban <victor@limogin.com>"
LABEL release=1.0

ENV PYTHONUNBUFFERED 1
ENV APPHOME /opt/services/djangoapp
ENV APPLOG /var/log/tucat

#### Install Mongodb Entreprise tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo 'deb http://repo.mongodb.com/apt/debian stretch/mongodb-enterprise/4.0 main' | tee /etc/apt/sources.list.d/mongodb-enterprise.list
RUN apt-get update
RUN apt-get install -y mongodb-enterprise-shell mongodb-enterprise-tools

RUN mkdir -p ${APPHOME}
RUN mkdir -p ${APPLOG}

WORKDIR ${APPHOME}

# Install dependencies
ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

## Install Tucat
RUN echo "Install Tucat Application " && \
	git clone https://github.com/natoinet/tucat ${APPHOME} #&& \
	git checkout sustainable

COPY ./tucat/.env ${APPHOME}

RUN echo "Output folder" && mkdir -p ${APPHOME}/tucat/tucat/output

RUN echo "Supervidor Configuration " && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor && \
    mkdir -p /etc/supervisor/conf.d

ADD supervisord/supervisord.conf /etc/supervisor/supervisord.conf
ADD supervisord/conf.d/celerybeat.conf  /etc/supervisor/conf.d/celerybeat.conf
ADD supervisord/conf.d/celeryd.conf     /etc/supervisor/conf.d/celeryd.conf
ADD supervisord/conf.d/tucat.conf       /etc/supervisor/conf.d/tucat.conf

RUN cd ${APPHOME} && python manage.py collectstatic --no-input
RUN ln -s ../djangoapp/tucat/output/ ../staticfiles

# Expose the port
EXPOSE 8000

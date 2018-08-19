## Dockerfile for TUCAT application 
## Tucat source code https://github.com/natoinet/tucat 
## sudo docker build -t natoinet/tucat . 

FROM python:3.6
LABEL authors="Antoine Brunel <antoine.brunel@gmail.com> & Victor Esteban <victor@limogin.com>"
LABEL release=1.0

ENV PYTHONUNBUFFERED 1
ENV APPHOME /opt/services/djangoapp/src
ENV APPLOG /var/log/tucat

#RUN /bin/bash -c "echo 'APPHOME ' ${APPHOME}"
RUN mkdir -p ${APPHOME}
#RUN mkdir -p ${APPLOG}

WORKDIR ${APPHOME}

# Install dependencies
ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

## Install Tucat
RUN echo "Install Tucat Application " && \
git clone https://github.com/natoinet/tucat ${APPHOME}
#COPY ./natoinet/tucat ${APPHOME}
COPY ./config/.env ${APPHOME}

RUN cd ${APPHOME} && python manage.py collectstatic --no-input

# Expose the port
EXPOSE 8000

## Default command to run when starting the container
CMD ["gunicorn", "-c", "config/gunicorn/conf.py", "--chdir", "tucat", "--bind", ":8000", "--log-file", "/var/log/tucat/gunicorn.log", "tucat.wsgi:application"]
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

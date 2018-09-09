#tucat-dockerfile 

Docker for Tucat, a generic software for extracting data from APIs.
First Draft for this dockerfile.

###Tucat source code
  [Tucat Source Code](https://github.com/natoinet/tucat) https://github.com/natoinet/tucat
  [Tucat-Dockerfile Source Code](https://github.com/natoinet/tucat-dockerfile) https://github.com/natoinet/tucat-dockerfile

###Get the projects
```
  git clone https://github.com/natoinet/tucat-dockerfile
  cd tucat-dockerfile
  git clone https://github.com/natoinet/tucat
```

###Setup your domain name
####In config > docker.py
```
  	ALLOWED_HOSTS = [ 'example.com' ]
```

###Setup the .env file
In tucat-dockerfile/tucat/.env, create .env file, for example with the following default values:
```
   DJANGO_SETTINGS_MODULE=config.settings.docker
   APPHOME=/opt/services/djangoapp
   APPLOG=/var/log/tucat
   MONGOCLIENT=mongodb://mongodb:27017
   RABBITMQ_DEFAULT_USER=guest
   RABBITMQ_DEFAULT_PASS=guest
   RABBITMQ_DEFAULT_VHOST=rabbitmq
   C_FORCE_ROOT=true
   MONGOHOST=mongodb
   POSTGRES_USER=dbtucat_role
   POSTGRES_PASSWORD=dbtucat_password
   POSTGRES_DB=dbtucat
```

####In config > nginx > local.conf
```
	server_name example.com;
```

###Build the image
```
  cd tucat-dockerfile
  sudo docker-compose build 
```

### Setup 

```
  sudo docker-compose run --rm djangoapp /bin/bash -c './manage.py createsuperuser'
  sudo docker-compose run --rm djangoapp /bin/bash -c './manage.py makemigrations application core users twitter_extraction twitter_streaming django_celery_beat'
  sudo docker-compose run --rm djangoapp /bin/bash -c './manage.py migrate'
```

###Setup RabbitMQ container access
```
   sudo docker exec -it tucat-dockerfile_rabbitmq_1 bash
   # rabbitmqctl add_vhost /
   # rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"
   # exit
```

### Run the container

```
  sudo docker-compose up
```


###Other notes

Connect to Django container
```
   sudo docker-compose run --rm djangoapp bash
```
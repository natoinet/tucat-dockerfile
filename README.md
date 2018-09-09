#tucat-dockerfile 

Docker for Tucat, a generic software for extracting data from APIs.
First Draft for this dockerfile.

###Tucat source code
  [Tucat Source Code](https://github.com/natoinet/tucat) https://github.com/natoinet/tucat


###Setup your domain name
####In config > docker.py
```
  	ALLOWED_HOSTS = [ 'example.com' ]
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
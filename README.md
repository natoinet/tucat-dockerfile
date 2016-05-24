#tucat-dockerfile 

Dockerfile build process for TUCAT 
TuCat is a generic tool to extract data from web APIs
First Draft for this dockerfile. It is necessary to establish the data persistence. 

###Tucat source code
  [Tucat Source Code](https://github.com/natoinet/tucat) https://github.com/natoinet/tucat

###Build the image

```
  sudo docker build --rm=true -t natoinet/tucat . 
```

###Run the container

```
  sudo docker run -d -p 8000:8000 -p 8080:80 -p 2020:22 -p 5432:5432 -p 27017:27017 --name tucat natoinet/tucat
```  

Or only with the essential ports to use the application 

```
  sudo docker run -d -p 8000:8000 -p 8080:80 -p 2020:22 --name tucat natoinet/tucat
```  

**Try to check the application**

```
  sudo docker exec -it tucat bash 
```  

or mounting volumes 

```
  sudo docker run -d -p 8080:80 -p 2020:22 -p 5432:5432 \
      -v /mnt/data/tucat/var/lib/postgresql:/var/lib/postgresql \
      -v /mnt/data/tucat/var/lib/mongodb:/var/lib/mongodb \
      natoinet/tucat 
```      

**Connecting to postgressql database**

```
  psql -U garbellador -h localhost -p 5432 dj_tucat  
```  

###Other notes

Removing untagged images 

```
  $ sudo docker rmi $(sudo docker images | grep "^<none>" | awk '{print $3}')
```

Removing all docker instances 

```
  $ sudo docker stop $(sudo docker ps -a -q)
  $ sudo docker rm $(sudo docker ps -a -q)
```

**Errors**

file: /home/antoinet/src/tucat/log/celery_worker.log

 raise ImproperlyConfigured(error_msg)
django.core.exceptions.ImproperlyConfigured: Set the DJANGO_SECRET_KEY environment variable
(tucat)antoinet@78e06701a362:~$ pip install django    

file: /home/antoinet/src/tucat/log/celery_worker.log

 File "/home/antoinet/.virtualenvs/tucat/lib/python3.4/site-packages/django/utils/log.py", line 71, in configure_logging
    logging_config_func(logging_settings)
  File "/usr/lib/python3.4/logging/config.py", line 789, in dictConfig
    dictConfigClass(config).configure()
  File "/usr/lib/python3.4/logging/config.py", line 565, in configure
    '%r: %s' % (name, e))
ValueError: Unable to configure handler 'file': [Errno 2] No such file or directory: '/home/antoinet/log/logging.log

file: /home/antoinet/src/tucat/log/gunicorn.log

  return self.load_wsgiapp()
  File "/home/antoinet/.virtualenvs/tucat/lib/python3.4/site-packages/gunicorn/app/wsgiapp.py", line 52, in load_wsgiapp
    return util.import_app(self.app_uri)
  File "/home/antoinet/.virtualenvs/tucat/lib/python3.4/site-packages/gunicorn/util.py", line 357, in import_app
    __import__(module)
ImportError: No module named 'tucat



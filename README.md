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
  sudo docker run -d -p 8000:8000 -p 8080:80 -p 2020:22 -p 15672:15672 -p 5672:5672 -p 5432:5432 -p 27017:27017 --name tucat natoinet/tucat
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

[2016-05-24 13:41:45,809: ERROR/MainProcess] consumer: Cannot connect to amqp://guest:**@127.0.0.1:5672//: [Errno 111] Connection refused.
Trying again in 2.00 seconds...

[2016-05-24 13:41:47,827: ERROR/MainProcess] consumer: Cannot connect to amqp://guest:**@127.0.0.1:5672//: [Errno 111] Connection refused.
Trying again in 4.00 seconds...

[2016-05-24 13:41:51,865: INFO/MainProcess] Connected to amqp://guest:**@127.0.0.1:5672//
[2016-05-24 13:41:51,887: INFO/MainProcess] mingle: searching for neighbors
[2016-05-24 13:41:52,906: INFO/MainProcess] mingle: all alone
[2016-05-24 13:41:52,982: WARNING/MainProcess] celery@dd8315014a01 ready.

file: /home/antoinet/src/tucat/log/gunicorn.log

[2016-05-24 11:42:31 +0000] [866] [ERROR] Retrying in 1 second.
[2016-05-24 11:42:32 +0000] [866] [ERROR] Can't connect to ('0.0.0.0', 8000)




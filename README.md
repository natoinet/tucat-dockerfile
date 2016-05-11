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

- 2016-04-28 07:51:03,182 INFO spawnerr: can't find command '/home/antoinet/.virtualenvs/tucat/bin/gunicorn'
- 2016-04-28 07:51:03,194 INFO spawnerr: can't find command '/home/antoinet/.virtualenvs/tucat/bin/python'


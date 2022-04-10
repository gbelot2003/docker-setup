# Docker | Apache 2.4 | PHP 7.3.7 | Mysql 5.7 | Phpmyadmin | SSL

## Installation
- git clone https://github.com/gbelot2003/docker-setup
- cd docker-setup
- git clone https://github.com/graymouser/decorilla src
- **Important** The folder of decorilla need's to be call **'src'**
- mkdir esdata
- mkdir logstash
- docker-compose up -d

and the project is working, from here, you just need to do as https://decorilla.atlassian.net/wiki/spaces/CTO/pages/903249921/Development+Setup

- just rename localhost:** for the service name, as example localhost:3306 of mysql is **mysql:3306** or localhost:9200 of elasticsearch is **"elasticsearch:9200"** and so on...

IF you need to add some services, just stop the docker service 

``` docker-compose down ```

and add the docker container under services in the docker-compose.yml

```
  kibana:
    container_name: kibana-srv
    image: docker.elastic.co/kibana/kibana:6.8.14
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    networks:
      - mynetwork
    depends_on:
      - elasticsearch
    ports:
      - 5601:5601
```


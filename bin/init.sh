#!/usr/bin/env sh

docker stop proxy && docker rm proxy; 
docker run --name proxy -d \
	-p 80:80 \
	-v /var/run/docker.sock:/tmp/docker.sock \
	-v "$PWD"/docker/nginx/proxy.conf:/etc/nginx/conf.d/proxy.conf:ro \
	-it jwilder/nginx-proxy

docker-compose build && docker-compose up -d && docker-compose logs -f
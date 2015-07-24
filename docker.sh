#!/bin/bash

echo -n "volume: "
read VOLUME

# Run docker mysql
docker run \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -d mysql 2>&1 >/dev/null

# Run docker wp
docker run \
  --name wp \
  --link mysql:mysql \
  -p 8000:80 \
  -v $(pwd)/$VOLUME:/var/www/html/wp-content/themes/docker \
  -d wordpress 2>&1 >/dev/null

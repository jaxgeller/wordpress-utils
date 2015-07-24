#!/bin/bash

echo -n "source wp install: "
read URL

echo -n "wp-admin username: "
read USER

echo -n "wp-admin password: "
read -s PASSWD

# Get initial login cookie of the current install
LOGIN_COOKIE=$( \
  curl -s \
  -H 'Cookie: wordpress_test_cookie=WP+Cookie+check' \
  $URL/wp-login.php?wpe-login=$USER \
  -d "log=$USER&pwd=$PASSWD&wp-submit=Log+In&testcookie=1" \
  -D -)
if [[ $? -ne 0 ]]; then
  echo "could not get initial login cookie. check credentials"
  exit 1
fi

# Gets backup of current install
curl -sb \
  <(echo "$LOGIN_COOKIE") \
  "$URL/wp-admin/export.php?download=true&content=all\
  &post_author=\0&post_start_date=0&post_end_date=0&\
  post_status=0&page_author=0&page_start_date=0&page_end_date=0&\
  page_status=0&submit=Download+Export+File" > backup.wp.xml

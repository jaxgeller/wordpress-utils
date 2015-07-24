#!/bin/bash

# get docker ip address
if [ "$(uname)" == "Darwin" ]; then
  IP="http://$(boot2docker ip):8000"
else
  IP="http://localhost:8000"
fi

# Start installing wp, sometimes docker takes a while to serve
curl -s "$IP/wp-admin/install.php" 2>&1 >/dev/null
while [ $? -ne 0 ]; do
  echo "retrying in 3"
  sleep 3
  curl -s "$IP/wp-admin/install.php" 2>&1 >/dev/null
done

# Install wp instance
curl -s -d \
  "weblog_title=TITLE&user_name=$USER&admin_password=$PASSWD&admin_password2=$PASSWD&admin_email=$USER@siteurl.com&Submit=Install WordPress" \
  "$IP/wp-admin/install.php?step=2" 2>&1 >/dev/null

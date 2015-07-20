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
  -d wordpress 2>&1 >/dev/null

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

# Get login cookie
COOKIE=$( \
  curl -s \
  -H "Cookie: wordpress_test_cookie=WP+Cookie+check" \
  -d "log=$USER&pwd=$PASSWD&wp-submit=Log+In&testcookie=1" \
  $IP/wp-login.php?wpe-login=$USER \
  -D -)

# Get nonces to install importer plugin
NONCE1=$( \
  curl -s \
  -b <(echo "$COOKIE") \
  "$IP/wp-admin/plugin-install.php?tab=plugin-information&plugin=wordpress-importer" \
  | grep "Install Now" \
  | grep -o -E 'href="([^"#]+)"' \
  | cut -d'"' -f2 \
  | cut -d '=' -f 4)

NONCE2=$( \
  curl -s \
  -b <(echo "$COOKIE") \
  "$IP/wp-admin/update.php?action=install-plugin&plugin=wordpress-importer&_wpnonce=$NONCE1&from=import" \
  | grep 'Activate this plugin' \
  | grep -o -E 'href="([^"#]+)"' \
  | cut -d '=' -f 6 \
  |  cut -d '"' -f 1)

# activate the importer plugin
curl -s \
  -b <(echo "$COOKIE") \
  "$IP/wp-admin/plugins.php?action=activate&from=import&plugin=wordpress-importer%2Fwordpress-importer.php&_wpnonce=$NONCE2" 2>&1 >/dev/null

# begin uploading file
UPLOAD_NONCE=$( \
  curl -s \
  -b <(echo "$COOKIE") \
  "$IP/wp-admin/admin.php?import=wordpress" \
  | grep "import-upload-form" \
  | grep -o -e 'wpnonce=[a-zA-z0-9]*' \
  | cut -d '=' -f 2)

# upload the backup file
UPLOAD_FILE=$( \
  curl -s \
  -b <(echo "$COOKIE") \
  -X POST \
  -F "import=@backup.wp.xml" \
  "$IP/wp-admin/admin.php?import=wordpress&step=1&_wpnonce=$UPLOAD_NONCE")

FILE_LOADED_NONCE=$( \
  echo "$UPLOAD_FILE" \
  | grep 'id="_wpnonce"' \
  | cut -d '>' -f 1 \
  | grep -o -e 'value="[a-zA-z0-9]*"' \
  | cut -d '"' -f 2 )


FILE_LOADED_ID=$( \
  echo "$UPLOAD_FILE" \
  | grep 'name="import_id"' \
  | grep -o -e 'value="."' \
  | cut -d '"' -f 2)

curl -s \
  -b <(echo "$COOKIE") \
  --data "_wpnonce=$FILE_LOADED_NONCE&import_id=$FILE_LOADED_ID" \
  "$IP/wp-admin/admin.php?import=wordpress&step=2" 2>&1 >/dev/null

rm backup.wp.xml
echo "all done!"

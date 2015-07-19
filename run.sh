#!/bin/bash

echo -n "source wp install"
read URL

echo -n "wp-admin username: "
read USER

echo -n "wp-admin password: "
read -s PASSWD


COOKIE=$(curl -s -H 'Cookie: wordpress_test_cookie=WP+Cookie+check' $URL/wp-login.php?wpe-login=$USER -d "log=$USER&pwd=$PASSWD&wp-submit=Log+In&testcookie=1" -D -)














# curl -s -b <(echo "$COOKIE") "$URL/wp-admin/export.php?download=true&content=all&post_author=0&post_start_date=0&post_end_date=0&post_status=0&page_author=0&page_start_date=0&page_end_date=0&page_status=0&submit=Download+Export+File" > backup.wp.xml

# docker run \
#   --name mysql \
#   -e MYSQL_ROOT_PASSWORD=password \
#   -d mysql

# docker run \
#   --name wp \
#   --link mysql:mysql \
#   -p 8000:80 \
#   -d wordpress

# IP=$(boot2docker ip)

# curl -s "http://dockerhost:8000/wp-admin/install.php"
# while [ $? -ne 0 ]; do
#   echo -ne "retrying in 3...\r"
#   sleep 3
#   curl -s "http://dockerhost:8000/wp-admin/install.php"
# done

# curl -s "http://dockerhost:8000/wp-admin/install.php?step=2" -d \
#   "weblog_title=WPTITLE&user_name=$USER&admin_password=$PASSWD&admin_password2=$PASSWD&admin_email=admin@siteurl.com&Submit=Install WordPress"

# NEW_COOKIE=$(curl -s -H 'Cookie: wordpress_test_cookie=WP+Cookie+check' http://dockerhost:8000/wp-login.php?wpe-login=$USER -d "log=$USER&pwd=$PASSWD&wp-submit=Log+In&testcookie=1" -D -)

# NONCE=$(curl -s -b <(echo "$NEW_COOKIE") "http://dockerhost:8000/wp-admin/plugin-install.php?tab=plugin-information&plugin=wordpress-importer" | grep "Install Now" | grep -o -E 'href="([^"#]+)"'| cut -d'"' -f2 | cut -d '=' -f 4)

# IMP_NONCE=$(curl -s -b <(echo "$NEW_COOKIE") "http://dockerhost:8000/wp-admin/update.php?action=install-plugin&plugin=wordpress-importer&_wpnonce=$NONCE&from=import" | grep 'Activate this plugin' | grep -o -E 'href="([^"#]+)"' | cut -d '=' -f 6 |  cut -d '"' -f 1)

# curl -s -b <(echo "$NEW_COOKIE") "http://dockerhost:8000/wp-admin/plugins.php?action=activate&from=import&plugin=wordpress-importer%2Fwordpress-importer.php&_wpnonce=$IMP_NONCE"



# UPLOAD_NONCE=$(curl -s -b <(echo "$NEW_COOKIE") "http://dockerhost:8000/wp-admin/admin.php?import=wordpress" | grep "import-upload-form" | grep -o -e 'wpnonce=[a-zA-z0-9]*' | cut -d '=' -f 2)

# FINAL_UPLOAD=$(curl -s -b <(echo "$NEW_COOKIE") -X POST --verbose -F "import=@backup.wp.xml" "http://dockerhost:8000/wp-admin/admin.php?import=wordpress&step=1&_wpnonce=$UPLOAD_NONCE")

# FINAL_UPLOAD_NONCE=$(echo "$FINAL_UPLOAD" | grep 'id="_wpnonce"' | cut -d '>' -f 1 | grep -o -e 'value="[a-zA-z0-9]*"' | cut -d '"' -f 2 )
# FINAL_UPLOAD_ID=$(echo "$FINAL_UPLOAD" | grep 'name="import_id"' | grep -o -e 'value="."' | cut -d '"' -f 2)


# curl -s -b <(echo "$NEW_COOKIE") --data "_wpnonce=$FINAL_UPLOAD_NONCE&import_id=$FINAL_UPLOAD_ID" "http://dockerhost:8000/wp-admin/admin.php?import=wordpress&step=2" > donezo.html

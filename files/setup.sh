#!/bin/sh
# Deploys a simple Apache webpage with kittens as a service.

# cd /tmp
apt-get -y update > /dev/null 2>&1
apt install -y apache2 > /dev/null 2>&1

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Hi!</title></head>
  <marquee><h1>Your demo is now ready</h1></marquee>
  </body>
</html>
EOM

echo "Your demo is now ready."
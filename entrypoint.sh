#!/bin/bash

PID_APP_SERVER=""
PID_NGINX=""

function cleanup
{
  if [ ! -z "$PID_APP_SERVER" ]; then
    kill $SERVER_PID
  fi 
  if [ ! -z "$PID_NGINX" ]; then
    kill $PID_NGINX
  fi
}
function finish()
{
  echo "============================="
  echo " FINISH() ..................."
  echo " HEARD SIGINT/SIGTERM ......."
  echo "============================="
  cleanup
}

#--- Main

trap finish SIGINT SIGTERM

# Copy self-signed cert created during image-build into the cert_export directory.
# This is for the host to import into browsers/https-clients for testing.
cp /opt/certs/* /opt/certs_export/

ruby /srv/echo_pqc_1/server.rb & PID_APP_SERVER=$!
echo "Got PID_APP_SERVER=$PID_APP_SERVER"

# nginx -g 'daemon off;'
nginx &
sleep 2 # Give nginx 2 seconds to boot
NGINX_PID_PATH="/var/run/nginx.pid"
if [ ! -f "$NGINX_PID_PATH" ]; then
  echo "ERROR: Expecting nginx PID file at $NGINX_PID_PATH"
  cleanup
  exit 1
fi

read PID_NGINX < "$NGINX_PID_PATH"
echo "Got PID_NGINX=$PID_NGINX"

# Now check if PID_NGINX is running
if ps -p $PID_NGINX > /dev/null 2>&1; then
  echo "AOK. PID_NGINX=$PID_NGINX is running."
else
  echo "NOK. PID_NGINX=$PID_NGINX is NOT running."
  echo "ERROR: Expecting NGINX at PID_NGINX to be running."
  cleanup
  exit 1
fi

wait $PID_APP_SERVER
wait $PID_NGINX



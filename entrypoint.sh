#!/bin/bash

function cleanup()
{
  echo "... HEARD SIGINT ..."
  kill $SERVER_PID
  pkill nginx
}
trap cleanup SIGINT

cp /opt/certs/* /opt/certs_export/

ruby /srv/echo_pqc_1/server.rb &
SERVER_PID="$?"
echo "Got SERVER_PID=$SERVER_PID"


nginx -g 'daemon off;'


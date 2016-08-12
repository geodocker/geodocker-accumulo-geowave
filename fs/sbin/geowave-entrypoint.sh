#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/accumulo-lib.sh

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
ACCUMULO_USER=${ACCUMULO_USER:-root}

if [ $ROLE = "register" ]; then
  wait_until_accumulo_is_available
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e \
    "createnamespace geowave"
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e \
    "config -s general.vfs.context.classpath.geowave=file:///usr/local/geowave/accumulo/[^.].*.jar"
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e \
    "config -ns geowave -s table.classpath.context=geowave"
  echo "Accumulo namespace configured: geowave"
elif [ $ROLE = "master" ]; then
  (setsid /sbin/geowave-entrypoint.sh register &> /tmp/geowave-register.log &)
  /sbin/entrypoint.sh "$@"
else
  /sbin/entrypoint.sh "$@"
fi

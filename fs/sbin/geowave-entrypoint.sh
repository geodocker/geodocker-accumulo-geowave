#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/accumulo-lib.sh

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
USER=${USER:-root}
ACCUMULO_USER=${ACCUMULO_USER:-root}

enable_iterators(){
  echo "Enabling iterators..."
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e "createnamespace geowave"
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e "config -s general.vfs.context.classpath.geowave=file:///usr/local/geowave/accumulo/geowave-accumulo.jar"
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e "config -ns geowave -s table.classpath.context=geowave"
}

if [[ $ROLE = "master" ]]; then
  runuser -p -u $USER -- wait_until_accumulo_is_available && sleep 5 && echo "Enabling iterators" && enable_iterators &
fi

echo "Entering accumulo entrypoint with args [$@]"
bash /sbin/entrypoint.sh "$@"

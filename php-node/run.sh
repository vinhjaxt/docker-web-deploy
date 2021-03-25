#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

HOST_NAME="php-node"

if [[ "$(docker images -q "${HOST_NAME}:latest" 2> /dev/null)" == "" || "$1" != "" ]]; then
  docker build -t "${HOST_NAME}:latest" "${DIR}/build"
  if [ $? -eq 0 ]; then
      echo 'Build done'
  else
      echo 'Build failed'
      exit 1
  fi
fi

docker container inspect "${HOST_NAME}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  docker stop "${HOST_NAME}"
  docker rm "${HOST_NAME}"
fi

docker run -d --restart=unless-stopped --name "${HOST_NAME}" --hostname "${HOST_NAME}" \
  -v "${DIR}/custom-php.ini:/usr/local/etc/php/conf.d/0-vinhjaxt-custom-php.ini:ro" \
  -v "${DIR}/custom-php-fpm.conf:/usr/local/etc/php-fpm.d/www.conf:ro" \
  -v "${DIR}/../logs/${HOST_NAME}:/home/logs:rw" \
  -v "${DIR}/../public_html/${HOST_NAME}:/home/public_html:rw" \
  -v "${DIR}/../data/${HOST_NAME}:/home/www-data:rw" \
  -v "${DIR}/../run/nginx/${HOST_NAME}:/home/run:rw" \
  -v "${DIR}/entrypoint.sh:/entrypoint.sh:ro" \
  --entrypoint="/entrypoint.sh" \
  -v "${DIR}/../run/mysql/mysqld:/var/run/mysqld:ro" \
  -e HOSTNAME=localhost \
  --cap-add=SYS_PTRACE \
  "${HOST_NAME}:latest" php-fpm

#!/usr/bin/env bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

if ! docker --version >/dev/null 2>&1 ; then
  echo 'Please install docker.'
  exit 1
fi

if [ ! -f "${DIR}/nginx/conf.d/inc/ssl-dhparams.pem" ]; then
  if ! openssl version >/dev/null 2>&1 ; then
    echo 'Please install openssl.'
    exit 1
  fi
  echo 1 > "${DIR}/nginx/conf.d/inc/ssl-dhparams.pem"
  openssl dhparam -out "${DIR}/nginx/conf.d/inc/ssl-dhparams.pem" 2048
fi

DOMAIN="your_domain.com"
docker run -p 80:80 --rm -v "${DIR}/logs/certbot/config:/tmp/certbot/config" certbot/certbot:latest --logs-dir "/tmp/certbot/log" --work-dir "/tmp/certbot/work" --config-dir "/tmp/certbot/config" \
  -d "$DOMAIN" --server https://acme-v02.api.letsencrypt.org/directory --standalone certonly --agree-tos -m "your_email@gmail.com"

if [ $? -ne 0 ]; then
  exit 1
fi

rm -rf "${DIR}/nginx/certs/$DOMAIN"
mkdir -p "${DIR}/nginx/certs/$DOMAIN" >/dev/null 2>&1
cp "${DIR}/logs/certbot/config/live/$DOMAIN/fullchain.pem" "${DIR}/logs/certbot/config/live/$DOMAIN/privkey.pem" "${DIR}/nginx/certs/$DOMAIN/"
chmod 777 -R "${DIR}/nginx/certs/$DOMAIN"

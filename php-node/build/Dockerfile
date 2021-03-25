FROM php:fpm-alpine
RUN apk add --no-cache tzdata
ENV TZ Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add php extensions
RUN apk add --no-cache --virtual .build-deps autoconf gcc make automake g++ make libffi-dev openssl-dev

# RUN docker-php-ext-install bcmath && docker-php-ext-enable bcmath
# RUN pecl install -o -f redis && docker-php-ext-enable redis

RUN apk add --no-cache oniguruma-dev
RUN docker-php-ext-install mbstring pdo pdo_mysql mysqli opcache && docker-php-ext-enable mbstring pdo pdo_mysql mysqli opcache

RUN apk del .build-deps
RUN rm -rf /tmp/pear
RUN rm -f /usr/local/etc/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/www.conf

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/etc/php/php.ini /usr/local/etc/php/conf.d/*
WORKDIR /home/

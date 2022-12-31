ARG MAJOR_PHP_VERSION=8.0

FROM php:${MAJOR_PHP_VERSION}-fpm-buster

ARG MAJOR_PHP_VERSION
ARG NGINX_VERSION=1.20~buster

LABEL maintainer="Aaron HS (asiraky@gmail.com)"

ENV TZ Australia/Sydney

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        curl gcc make autoconf libc-dev zlib1g-dev libicu-dev g++ pkg-config gnupg2 dirmngr wget apt-transport-https lsb-release ca-certificates \
        python-pip python-setuptools git default-mysql-client libmemcached-dev libz-dev libpq-dev libjpeg-dev libpng-dev libfreetype6-dev \
        libssl-dev libwebp-dev libmcrypt-dev libonig-dev libxrender1 libxext6 librdkafka-dev openssh-server nginx

RUN set -eux; \
    # install php pdo_mysql extention
    docker-php-ext-install pdo_mysql; \
    # install php pdo_pgsql extention
    docker-php-ext-install pdo_pgsql; \
    # install php gd library
    docker-php-ext-configure gd \
        --prefix=/usr \
        --with-jpeg \
        --with-webp \
        --with-freetype; \
    docker-php-ext-install gd; \
    # install php pcntl lib
    docker-php-ext-install pcntl; \
    # install php opcache lib
    docker-php-ext-install opcache; \
    # install php sockets
    docker-php-ext-install sockets; \
    # install php bcmath
    docker-php-ext-install bcmath; \
    # install php intl
    docker-php-ext-configure intl; \
    docker-php-ext-install intl; \
    php -r 'var_dump(gd_info());'

RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
    apt-utils \
    libzip-dev zip unzip && \
    docker-php-ext-configure zip; \
    docker-php-ext-install zip && \
    php -m | grep -q 'zip'

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# configure locale
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

# clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# output the php version for verification
RUN set -xe; php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

ARG PHP_OPCACHE_VALIDATE_TIMESTAMPS=0
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=$PHP_OPCACHE_VALIDATE_TIMESTAMPS

# copy over laravel specific php ini
COPY laravel.ini /usr/local/etc/php/conf.d
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
COPY opcache.ini /usr/local/etc/php/conf.d

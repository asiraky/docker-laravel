FROM php:8.2-fpm-buster

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        git curl gcc make autoconf libc-dev zlib1g-dev libicu-dev g++ pkg-config gnupg2 dirmngr wget \
        apt-transport-https lsb-release ca-certificates python-pip python-setuptools libjpeg62 \
        default-mysql-client libmemcached-dev libz-dev libpq-dev libjpeg-dev libpng-dev libfreetype6-dev \
        libssl-dev libwebp-dev libmcrypt-dev libonig-dev libxrender1 libxext6 librdkafka-dev \
        openssh-server libmagickwand-dev apt-utils libzip-dev zip unzip nano iputils-ping supervisor

# install PHP extensions
RUN docker-php-ext-configure gd --prefix=/usr --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install pdo_mysql pdo_pgsql opcache pcntl zip mbstring exif pcntl bcmath -j$(nproc) gd intl

RUN pecl install redis && docker-php-ext-enable redis

# install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

RUN pecl channel-update pecl.php.net && \
    pecl install imagick && \
    docker-php-ext-enable imagick

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# configure locale
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

# clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN rm -rf /var/www/html

WORKDIR /var/www

# copy over laravel specific php ini
COPY php-fpm/laravel.ini /usr/local/etc/php/conf.d/laravel.ini

# copy over production php configuration
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# copy over opcache configration
COPY php-fpm/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# copy over supervisord configuration
ADD php-fpm/supervisord.conf /etc/supervisor/supervisord.conf

# copy over php-pfm configuration
ADD php-fpm/docker.conf /usr/local/etc/php-fpm.d/zzz-docker.conf

# start supervisord
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
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
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql pdo_pgsql pcntl zip mbstring exif pcntl bcmath -j$(nproc) gd intl

RUN pecl install redis && docker-php-ext-enable redis

# install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

RUN pecl channel-update pecl.php.net

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# configure locale
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

# clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# copy over laravel specific php ini
COPY laravel.ini /usr/local/etc/php/conf.d

# copy over production php configuration
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# copy over opcache configration
COPY opcache.ini /usr/local/etc/php/conf.d

# copy over supervisord configuration
ADD supervisord.conf /etc/supervisor/supervisord.conf

# start supervisord
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
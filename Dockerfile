FROM php:7-fpm

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
       && php -r "if (hash_file('SHA384', 'composer-setup.php') === '070854512ef404f16bac87071a6db9fd9721da1684cd4589b1196c3faf71b9a2682e2311b36a5079825e155ac7ce150d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
       && php composer-setup.php --install-dir=/usr/bin \
       && ln -s /usr/bin/composer.phar /usr/bin/composer \
       && rm composer-setup.php

RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony \
       && chmod a+x /usr/local/bin/symfony

RUN apt-get update && apt-get install -y git \
       && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
libpq-dev \
libmemcached-dev \
libpng-dev \
curl \
--no-install-recommends \
&& rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install \
pdo_mysql \
pdo_pgsql \
gd

WORKDIR /var/www

FROM php:7-fpm

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin \
   && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony \
       && chmod a+x /usr/local/bin/symfony

RUN apt-get update && apt-get install -y git \
       && rm -rf /var/lib/apt/lists/*

# Install opcache
RUN docker-php-ext-install opcache

# xdebug-2.4.0beta1 supports PHP7 (boom!)
RUN touch /usr/local/etc/php/conf.d/xdebug.ini; \
	echo [xdebug] >>  /usr/local/etc/php/conf.d/xdebug.ini; \
	echo  "zend_extension = xdebug.so" >>  /usr/local/etc/php/conf.d/xdebug.ini; \
	echo xdebug.remote_enable=1 >> /usr/local/etc/php/conf.d/xdebug.ini; \
  	echo xdebug.remote_autostart=0 >> /usr/local/etc/php/conf.d/xdebug.ini; \
  	echo xdebug.remote_connect_back=1 >> /usr/local/etc/php/conf.d/xdebug.ini; \
  	echo xdebug.remote_port=9000 >> /usr/local/etc/php/conf.d/xdebug.ini; \
  	echo xdebug.remote_log=/tmp/php5-xdebug.log >> /usr/local/etc/php/conf.d/xdebug.ini

RUN	curl -LsS -o xdebug-2.4.0beta1.tgz http://xdebug.org/files/xdebug-2.4.0beta1.tgz && \
	tar -xvzf xdebug-2.4.0beta1.tgz && \
	cd xdebug-2.4.0beta1 && \
	phpize && \
	./configure && \
	make && \
	cp modules/xdebug.so `php-config --extension-dir` && \
        cd .. && rm -rf xdebug-2.4.0beta1

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt pdo_mysql \ 
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -rf /var/lib/apt/lists/*

# PostgresSQL
RUN apt-get update; \
        apt-get install -y  libpq-dev; \
        docker-php-ext-install pdo_pgsql

# intl
RUN apt-get install -y libicu-dev
RUN pecl install intl
RUN docker-php-ext-install intl

RUN rm -rf /var/lib/apt/lists/*

RUN touch /usr/local/etc/php/conf.d/aopcache.ini;\
        echo [opcache] >> /usr/local/etc/php/conf.d/aopcache.ini ;\
        echo zend_extension=opcache.so >> /usr/local/etc/php/conf.d/aopcache.ini ;\
        echo opcache.enable=1 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.memory_consumption=32 >> /usr/local/etc/php/conf.d/aopcache.ini ; \
        echo opcache.interned_strings_buffer=8 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.max_accelerated_files=3000 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.revalidate_freq=180 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.fast_shutdown=0 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.enable_cli=0 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.revalidate_path=0 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.validate_timestamps=2 >> /usr/local/etc/php/conf.d/aopcache.ini; \
        echo opcache.max_file_size=0 >> /usr/local/etc/php/conf.d/aopcache.ini 

WORKDIR /var/www

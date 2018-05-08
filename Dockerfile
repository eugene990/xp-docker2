FROM ubuntu:16.04

MAINTAINER Eugene Vasiltsov <eugenevasilsov@gmail.com>

# install php 7.1
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends --no-install-suggests && \
    apt-get install software-properties-common python-software-properties -y --no-install-recommends --no-install-suggests && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install php7.1-fpm php7.1-cli -y --no-install-recommends --no-install-suggests

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    nginx \
    ca-certificates \
    gettext \
    mc \
    libmcrypt-dev  \
    libicu-dev \
    libcurl4-openssl-dev \
    mysql-client \
    libldap2-dev \
    libfreetype6-dev \
    libfreetype6 \
    libpng12-dev \
    curl \
    bash \
    openssh-server \
    cron \
    vim

# exts
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    php-pear \
    php7.1-mongodb \
    php7.1-curl \
    php7.1-intl \
    php7.1-soap \
    php7.1-xml \
    php-mcrypt \
    php7.1-bcmath \
    php7.1-mysql \
    php7.1-mysqli \
    php7.1-amqp \
    php7.1-mbstring \
    php7.1-ldap \
    php7.1-zip \
    php7.1-iconv \
    php7.1-pdo \
    php7.1-json \
    php7.1-simplexml \
    php7.1-xmlrpc \
    php7.1-gmp \
    php7.1-fileinfo \
    php7.1-sockets \
    php7.1-ldap \
    php7.1-gd \
    php7.1-xdebug && \
    echo "extension=apcu.so" | tee -a /etc/php/7.1/mods-available/cache.ini

# Install git core
RUN apt-get install -y --no-install-recommends --no-install-suggests \
    git-core

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
RUN chmod 777 /nodesource_setup.sh
RUN /nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install -g bower
RUN npm install --global gulp

# Install mail server
COPY mailserver.sh /tmp/mailserver.sh
RUN /tmp/mailserver.sh

# set timezone Europe/Moscow
RUN cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	&& ln -sf /dev/stderr /var/log/php7.1-fpm.log

RUN rm -f /etc/nginx/sites-enabled/*
COPY ./etc/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /root/.ssh
RUN chmod 600 /root/.ssh

RUN mkdir -p /run/php && touch /run/php/php7.1-fpm.sock && touch /run/php/php7.1-fpm.pid
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
EXPOSE 80

WORKDIR /var/www


CMD ["/entrypoint.sh"]

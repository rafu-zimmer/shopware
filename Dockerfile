FROM php:8.2-fpm-alpine

ENV COMPOSER_HOME=/var/cache/composer
ENV ARTIFACTS_DIR=/artifacts
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so

RUN apk --no-cache add \
        supervisor curl zip libzip-dev rsync xz coreutils icu-dev \
        php-ctype php-curl php-dom php-fileinfo php-gd \
        php-iconv php-json php-mbstring \
        php-openssl \
        php-session php-simplexml php-tokenizer php-xml php-xmlreader php-xmlwriter \
        php-zip php-zlib php-phar php-opcache php-sodium git \
        gnu-libiconv \
    && mkdir -p /var/cache/composer

RUN docker-php-ext-install mysqli pdo_mysql \
    && docker-php-ext-enable mysqli pdo_mysql

RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && apk del pcre-dev ${PHPIZE_DEPS} \
  && rm -rf /tmp/pear \


RUN docker-php-ext-configure intl zip && docker-php-ext-install intl zip

RUN apk add bash npm

# nvm environment variables
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=18

# install nvm
# https://github.com/creationix/nvm#install-script
RUN mkdir $NVM_DIR && curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use --delete-prefix default

# Copy system configs
COPY config/etc /etc

COPY --from=composer/composer:2-bin /composer /usr/bin/composer

WORKDIR /var/www

#RUN APP_URL="http://localhost" DATABASE_URL="" bin/console assets:install \
#    && rm -Rf var/cache \
#    && touch install.lock \
#    && mkdir -p var/cache

#
## Let supervisord start nginx & php-fpm
#ENTRYPOINT ["./bin/entrypoint.sh"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8000/fpm-ping

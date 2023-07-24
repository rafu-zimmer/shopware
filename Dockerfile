FROM php:8.2-fpm-alpine

ENV COMPOSER_HOME=/var/cache/composer
ENV ARTIFACTS_DIR=/artifacts
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so

RUN apk --no-cache add \
        supervisor curl zip rsync xz coreutils icu-dev \
        php-ctype php-curl php-dom php-fileinfo php-gd \
        php-iconv php-json php-mbstring \
        php-openssl \
        php-session php-simplexml php-tokenizer php-xml php-xmlreader php-xmlwriter \
        php-zip php-zlib php-phar php-opcache php-sodium git \
        gnu-libiconv \
    && mkdir -p /var/cache/composer

RUN docker-php-ext-install mysqli pdo_mysql \
    && docker-php-ext-enable mysqli pdo_mysql

RUN docker-php-ext-configure intl && docker-php-ext-install intl

RUN apk add bash npm

# Copy system configs
COPY config/etc /etc

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

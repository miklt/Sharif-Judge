FROM php:7.3-apache
RUN apt-get clean && apt-get update \ 
&& apt-get install --fix-missing -y wget apt-transport-https lsb-release ca-certificates gnupg2 libpq-dev nano g++ ruby-dev \
&& docker-php-ext-install pdo pdo_pgsql pgsql
RUN mkdir /app
RUN chown -R www-data:www-data /app && a2enmod rewrite

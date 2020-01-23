FROM php:7.3-apache
RUN apt-get clean && apt-get update \ 
&& apt-get install --fix-missing -y wget apt-transport-https lsb-release ca-certificates gnupg2 libpq-dev nano g++ ruby-dev \
&& docker-php-ext-install pdo pdo_pgsql pgsql
RUN mkdir /app
RUN mkdir /assignments
RUN mkdir /tester
COPY ./application /app/application
COPY ./index.php /app
COPY ./robots.txt /app
COPY ./assets /app/assets
COPY ./selenium-tests /app/selenium-tests
COPY ./system /app/system
COPY ./vendor /app/vendor
COPY ./assignments /assignments
COPY ./tester /tester
RUN chown -R www-data:www-data /assignments 
RUN chown -R www-data:www-data /tester 
RUN chown -R www-data:www-data /app && a2enmod rewrite

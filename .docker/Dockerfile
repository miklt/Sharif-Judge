FROM php:7.3-apache
#FROM php:5.6-apache
RUN mkdir -p /usr/share/man/man1
#RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list

RUN apt-get clean && apt-get update && apt-get install --fix-missing -y \
apt-transport-https \
libpq-dev \
wget \
libxext6 \
libfreetype6-dev \
libjpeg62-turbo-dev \
libpng-dev \
libmcrypt-dev \
libxslt-dev \
libpcre3-dev \
libxrender1 \
libfontconfig \
uuid-dev \
ghostscript \
curl \
wget \
lsb-release \
#ca-certificates \
gnupg2 \
nano \
g++ \
ruby-dev \
&& docker-php-ext-install pdo pdo_pgsql pgsql 
RUN apt-get install -y default-jdk
RUN mkdir /var/www/judge
RUN mkdir /var/www/judge/pcs3616
RUN mkdir /var/www/judge/pcs3616/assignments
RUN mkdir /var/www/judge/pcs3616/tester
COPY ./application /var/www/judge/pcs3616/application
COPY ./index.php /var/www/judge/pcs3616
COPY ./robots.txt /var/www/judge/pcs3616
COPY ./assets /var/www/judge/pcs3616assets
COPY ./selenium-tests /var/www/judge/pcs3616selenium-tests
COPY ./system /var/www/judge/pcs3616/system
COPY ./vendor /var/www/judge/pcs3616/vendor
COPY ./assignments /var/www/judge/pcs3616/assignments
COPY ./tester /var/www/judge/pcs3616/tester
#RUN mkdir /app
#RUN mkdir /assignments
#RUN mkdir /tester
# COPY ./application /app/application
# COPY ./index.php /app
# COPY ./robots.txt /app
# COPY ./assets /app/assets
# COPY ./selenium-tests /app/selenium-tests
# COPY ./system /app/system
# COPY ./vendor /app/vendor
# COPY ./assignments /app/assignments
# COPY ./tester /app/tester
RUN gem install byebug --no-document
RUN gem install paint --no-document

RUN chown -R www-data:www-data /var/www/judge/pcs3616 && a2enmod rewrite
#RUN chown -R www-data:www-data /assignments 
#RUN chown -R www-data:www-data /tester 


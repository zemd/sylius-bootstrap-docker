FROM php:7.2-fpm
MAINTAINER Dmytro Zelenetskyi <dmytro.zelenetskyi@gmail.com>

ENV TZ UTC
# There is a warning during build process `[warning] debconf: delaying package configuration`
# This variable and `apt-utils` package installation should solve this issue
# @see https://github.com/tianon/docker-brew-ubuntu-core/issues/59#issuecomment-241154499
ARG DEBIAN_FRONTEND=noninteractive
ARG COMPOSER_SIGNATURE="544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061"
# Allow run composer from root and supress warning message, @see https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
#	&& echo $TZ > /etc/timezone \
#	&& dpkg-reconfigure -f noninteractive tzdata

# All things PHP
# libpng-dev is required by gd extention
# libicu-dev is required by intl extention
# curl, zip, unzip, git are required by composer
# hirak/prestissimo is a composer parallel install plugin
# php zip extention is required by composer
# libzip-dev is required by zip extention, @see https://stackoverflow.com/a/48700777/263321 (but keep in mind there is a warning still appears "configure: WARNING: Libzip >= 1.2.0 needed for encryption support")
# libjpeg62-turbo-dev is required to support JPEG in php-gd extention
# libfreetype6-dev is required by php-gd extention
# libpng-dev is required by php-gd extention
RUN apt-get update \
	&& apt-get install -y libpng-dev libicu-dev apt-utils curl zip unzip git libzip-dev libjpeg62-turbo-dev libfreetype6-dev libpng-dev --no-install-recommends \
	&& pecl install xdebug-2.6.0 \
 	&& docker-php-ext-configure zip --with-libzip \
 	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
 	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-install \
		exif \
		fileinfo \
		intl \
		pdo \
		pdo_mysql \
		zip \
	&& docker-php-ext-enable \
		opcache \
		xdebug \
	&& php -r "readfile('https://getcomposer.org/installer');" > "/tmp/composer-setup.php" \
	&& php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$COMPOSER_SIGNATURE') { echo 'Installer verified'; } else { echo 'Installer `composer-setup.php` corrupted'; } echo PHP_EOL;" \
	&& php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& rm -f /tmp/composer-setup.php \
 	&& composer global require hirak/prestissimo \
 	&& mkdir /run/php \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PHP configuration
COPY sylius.ini /usr/local/etc/php/conf.d/sylius.ini
# PHP-FPM configuration
COPY www_extra.conf /usr/local/etc/php-fpm.d/www_extra.conf

EXPOSE 9000
# https://stackoverflow.com/a/36130772/263321
CMD ["php-fpm", "-F", "--allow-to-run-as-root"]

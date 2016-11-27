# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.18

# app directories
ENV WATERGO /watergo
ENV API $WATERGO/api

# install php7
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y software-properties-common python-software-properties git \
	&& LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php \
	&& apt-get update \
	&& apt-get install -y php7.0 php7.0-fpm php7.0-cli php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-mbstring php7.0-dev php7.0-xml php7.0-json php7.0-zip nginx\
	&& apt-get --purge autoremove -y \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# install xdebug
# default host ip of docker-machine
RUN pecl install -o -f xdebug apcu
RUN echo "zend_extension=$(find /usr/lib/php/20151012/ -name xdebug.so)" > /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_autostart=1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_host=10.254.254.254" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.max_nesting_level=512" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_log=/var/log/xdebug.log" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.profiler_enable=0" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.coverage_enable=0" >> /etc/php/7.0/mods-available/xdebug.ini \
    && ln -sf /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/fpm/conf.d/20-xdebug.ini \
    && ln -sf /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini

# install composer
RUN cd /root && { curl -sS https://getcomposer.org/installer | /usr/bin/php && /bin/mv -f /root/composer.phar /usr/local/bin/composer; cd -; }

RUN mkdir /etc/service/nginx \
    && mkdir /etc/service/php-fpm

COPY ./docker/service/nginx/run /etc/service/nginx/run
COPY ./docker/service/php-fpm/run /etc/service/php-fpm/run

# ensure dir owned by www-data (wpzoom plugin needs write permissions)
# @see http://container-solutions.com/understanding-volumes-docker/
# @see http://stackoverflow.com/a/33615398
RUN usermod -u 1000 www-data
RUN mkdir -p $WATERGO
RUN chown -R :www-data $WATERGO

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

EXPOSE 80
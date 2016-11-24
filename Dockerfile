# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.18

# install php7
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y software-properties-common git \
	&& LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php \
	&& apt-get update \
	&& apt-get install -y php7.0 php7.0-fpm php7.0-cli php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-dev nginx\
	&& apt-get --purge autoremove -y \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# install composer
RUN cd /root && { curl -sS https://getcomposer.org/installer | /usr/bin/php && /bin/mv -f /root/composer.phar /usr/local/bin/composer; cd -; }

RUN mkdir /etc/service/nginx \
    && mkdir /etc/service/php-fpm

COPY ./docker/service/nginx/run /etc/service/nginx/run
COPY ./docker/service/php-fpm/run /etc/service/php-fpm/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
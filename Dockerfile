FROM alpine:3.19 as wp-download
WORKDIR /tmp
ADD https://wordpress.org/wordpress-6.5.3.tar.gz wordpress.tar.gz
RUN echo "8e4950d39990a2c200a7745d44d32b176baa5ac5 *wordpress.tar.gz" | sha1sum -c && \
	tar zxf wordpress.tar.gz && \
	rm -f -- wordpress/readme.html

FROM wordpress:cli as wp-cli

FROM alpine:3.19
RUN apk update && \
	apk --no-cache upgrade
RUN apk add --no-cache \
	bash \
	less \
	msmtp \
	mysql-client \
	php82 \
	php82-bcmath \
	php82-bz2 \
	php82-ctype \
	php82-curl \
	php82-dom \
	php82-exif \
	php82-fileinfo \
	php82-gd \
	php82-gettext \
	php82-iconv \
	php82-intl \
	php82-json \
	php82-mbstring \
	php82-mysqli \
	php82-opcache \
	php82-openssl \
	php82-pecl-redis \
	php82-pecl-imagick \
	php82-phar \
	php82-simplexml \
	php82-tokenizer \
	php82-xml \
	php82-xmlreader \
	php82-xmlwriter \
	php82-xsl \
	php82-zip \
	shadow \
	su-exec \
	tini \
	unit-php82 \
	unzip

RUN addgroup -g 10005 -S appuser && \
	adduser -u 10005 -G appuser -S -s /usr/sbin/nologin -h /home/appuser appuser

COPY --from=wp-download --chown=appuser:appuser /tmp/wordpress /site
COPY --chown=appuser:appuser wp-config-docker.php /site/wp-config.php
COPY --from=wp-cli /usr/local/bin/wp /usr/bin/wp
COPY ./unit-conf.json.template /var/lib/unit/conf.json.template
COPY ./docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY ./msmtprc /etc/msmtprc

RUN sed -i \
	-e 's:memory_limit = 128M:memory_limit = 256M:g' \
	-e 's:^;sendmail_path.*:sendmail_path = "/usr/bin/msmtp -t":' \
	/etc/php82/php.ini
RUN install -d -m 1777 /usr/tmp && \
	chmod 555 /sbin/docker-entrypoint.sh

EXPOSE 8080
WORKDIR /site

ENTRYPOINT ["/sbin/tini", "--", "/sbin/docker-entrypoint.sh"]
CMD ["app"]

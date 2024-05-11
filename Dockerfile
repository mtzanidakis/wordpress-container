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
	php81 \
	php81-bcmath \
	php81-bz2 \
	php81-ctype \
	php81-curl \
	php81-dom \
	php81-exif \
	php81-fileinfo \
	php81-gd \
	php81-gettext \
	php81-iconv \
	php81-intl \
	php81-json \
	php81-mbstring \
	php81-mysqli \
	php81-opcache \
	php81-openssl \
	php81-pecl-redis \
	php81-pecl-imagick \
	php81-phar \
	php81-simplexml \
	php81-tokenizer \
	php81-xml \
	php81-xmlreader \
	php81-xmlwriter \
	php81-xsl \
	php81-zip \
	shadow \
	su-exec \
	tini \
	unit-php81 \
	unzip

RUN addgroup -g 10005 -S appuser && \
	adduser -u 10005 -G appuser -S -s /usr/sbin/nologin -h /home/appuser appuser

COPY --from=wp-download --chown=appuser:appuser /tmp/wordpress /site
COPY --chown=appuser:appuser wp-config-docker.php /site/wp-config.php
COPY --from=wp-cli /usr/local/bin/wp /usr/bin/wp
COPY ./unit-conf.json.template /var/lib/unit/conf.json.template
COPY ./docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY ./msmtprc /etc/msmtprc

RUN ln -sf php81 /usr/bin/php && \
	ln -sf phar.phar81 /usr/bin/phar.phar && \
	ln -sf phar81 /usr/bin/phar

RUN sed -i \
	-e 's:memory_limit = 128M:memory_limit = 256M:g' \
	-e 's:^;sendmail_path.*:sendmail_path = "/usr/bin/msmtp -t":' \
	/etc/php81/php.ini
RUN install -d -m 1777 /usr/tmp && \
	chmod 555 /sbin/docker-entrypoint.sh

EXPOSE 8080
WORKDIR /site

ENTRYPOINT ["/sbin/tini", "--", "/sbin/docker-entrypoint.sh"]
CMD ["app"]

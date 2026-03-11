FROM alpine:3.23 AS wp-download
WORKDIR /tmp
ADD https://wordpress.org/wordpress-6.9.4.tar.gz wordpress.tar.gz
RUN echo "018542f4c3e15db0d8e38aaf0fcf1b5dc56dbb79 *wordpress.tar.gz" | sha1sum -c && \
	tar zxf wordpress.tar.gz && \
	rm -f -- wordpress/readme.html

FROM wordpress:cli AS wp-cli

FROM alpine:3.23
RUN apk update && \
	apk --no-cache upgrade
RUN apk add --no-cache \
	bash \
	less \
	msmtp \
	mysql-client \
	php85 \
	php85-bcmath \
	php85-bz2 \
	php85-ctype \
	php85-curl \
	php85-dom \
	php85-exif \
	php85-fileinfo \
	php85-gd \
	php85-gettext \
	php85-iconv \
	php85-intl \
	php85-json \
	php85-mbstring \
	php85-mysqli \
	php85-openssl \
	php85-pecl-redis \
	php85-pecl-imagick \
	php85-phar \
	php85-simplexml \
	php85-tokenizer \
	php85-xml \
	php85-xmlreader \
	php85-xmlwriter \
	php85-xsl \
	php85-zip \
	shadow \
	su-exec \
	tini \
	unit-php85 \
	unzip

RUN addgroup -g 10005 -S appuser && \
	adduser -u 10005 -G appuser -S -s /usr/sbin/nologin -h /home/appuser appuser

COPY --from=wp-download --chown=appuser:appuser /tmp/wordpress /site
COPY --chown=appuser:appuser wp-config-docker.php /site/wp-config.php
COPY --from=wp-cli /usr/local/bin/wp /usr/bin/wp
COPY ./unit-conf.json.template /var/lib/unit/conf.json.template
COPY ./docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY ./apprun.sh /usr/bin/apprun
COPY ./msmtprc /etc/msmtprc

RUN ln -sf php85 /usr/bin/php && \
	ln -sf phar85 /usr/bin/phar && \
	ln -sf phar.phar85 /usr/bin/phar.phar

RUN sed -i \
	-e 's:memory_limit = 128M:memory_limit = 256M:g' \
	-e 's:^;\(opcache.enable=1\):\1:' \
	-e 's:^;\(opcache.enable_cli=\)0:\11:' \
	-e 's:^;sendmail_path.*:sendmail_path = "/usr/bin/msmtp -t":' \
	/etc/php85/php.ini
RUN install -d -m 1777 /usr/tmp && \
	chmod 555 /sbin/docker-entrypoint.sh /usr/bin/apprun

EXPOSE 8080
WORKDIR /site

ENTRYPOINT ["/sbin/tini", "--", "/sbin/docker-entrypoint.sh"]
CMD ["app"]

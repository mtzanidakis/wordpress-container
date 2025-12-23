FROM alpine:3.23 AS wp-download
WORKDIR /tmp
ADD https://wordpress.org/wordpress-6.9.tar.gz wordpress.tar.gz
RUN echo "256dda5bb6a43aecd806b7a62528f442c06e6c25 *wordpress.tar.gz" | sha1sum -c && \
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
	php83 \
	php83-bcmath \
	php83-bz2 \
	php83-ctype \
	php83-curl \
	php83-dom \
	php83-exif \
	php83-fileinfo \
	php83-gd \
	php83-gettext \
	php83-iconv \
	php83-intl \
	php83-json \
	php83-mbstring \
	php83-mysqli \
	php83-opcache \
	php83-openssl \
	php83-pecl-redis \
	php83-pecl-imagick \
	php83-phar \
	php83-simplexml \
	php83-tokenizer \
	php83-xml \
	php83-xmlreader \
	php83-xmlwriter \
	php83-xsl \
	php83-zip \
	shadow \
	su-exec \
	tini \
	unit-php83 \
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

RUN ln -sf php83 /usr/bin/php && \
	ln -sf phar83 /usr/bin/phar && \
	ln -sf phar.phar83 /usr/bin/phar.phar

RUN sed -i \
	-e 's:memory_limit = 128M:memory_limit = 256M:g' \
	-e 's:^;sendmail_path.*:sendmail_path = "/usr/bin/msmtp -t":' \
	/etc/php83/php.ini
RUN install -d -m 1777 /usr/tmp && \
	chmod 555 /sbin/docker-entrypoint.sh /usr/bin/apprun

EXPOSE 8080
WORKDIR /site

ENTRYPOINT ["/sbin/tini", "--", "/sbin/docker-entrypoint.sh"]
CMD ["app"]

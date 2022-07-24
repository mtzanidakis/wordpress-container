FROM alpine:3.16.1 as wp-download
ARG SUM=a1c02b6b754d74c08a70d5a8b604bdb72f1b276a
ARG VERSION
WORKDIR /tmp
ADD https://wordpress.org/wordpress-${VERSION}.tar.gz wordpress.tar.gz
RUN echo "${SUM} *wordpress.tar.gz" | sha1sum -c && \
	tar zxf wordpress.tar.gz && \
	rm -f -- wordpress/readme.html

FROM wordpress:cli as wp-cli

FROM alpine:3.16.1
RUN apk add --no-cache \
	bash \
	less \
	msmtp \
	mysql-client \
	php8 \
	php8-bcmath \
	php8-bz2 \
	php8-ctype \
	php8-curl \
	php8-dom \
	php8-exif \
	php8-fileinfo \
	php8-gd \
	php8-gettext \
	php8-iconv \
	php8-intl \
	php8-json \
	php8-mbstring \
	php8-mysqli \
	php8-opcache \
	php8-openssl \
	php8-pecl-redis \
	php8-pecl-imagick \
	php8-phar \
	php8-simplexml \
	php8-tokenizer \
	php8-xml \
	php8-xmlreader \
	php8-xmlwriter \
	php8-xsl \
	php8-zip \
	shadow \
	su-exec \
	tini \
	unit-php8 \
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
	/etc/php8/php.ini
RUN install -d -m 1777 /usr/tmp && \
	chmod 555 /sbin/docker-entrypoint.sh

EXPOSE 8080
WORKDIR /site

ENTRYPOINT ["/sbin/tini", "--", "/sbin/docker-entrypoint.sh"]
CMD ["app"]

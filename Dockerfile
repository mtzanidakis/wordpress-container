FROM alpine:3.15 as wp-download
ARG SUM=15746f848cd388e270bae612dccd0c83fa613259
ARG VERSION
WORKDIR /tmp
ADD https://wordpress.org/wordpress-${VERSION}.tar.gz wordpress.tar.gz
RUN echo "${SUM} *wordpress.tar.gz" | sha1sum -c && \
	tar zxf wordpress.tar.gz && \
	rm -f -- wordpress/readme.html

FROM wordpress:cli as wp-cli

FROM alpine:3.15
RUN apk add --no-cache \
	bash \
	less \
	msmtp \
	mysql-client \
	php7 \
	php7-bcmath \
	php7-bz2 \
	php7-ctype \
	php7-curl \
	php7-dom \
	php7-exif \
	php7-fileinfo \
	php7-gd \
	php7-gettext \
	php7-iconv \
	php7-intl \
	php7-json \
	php7-mbstring \
	php7-mysqli \
	php7-opcache \
	php7-openssl \
	php7-pecl-redis \
	php7-pecl-imagick \
	php7-phar \
	php7-simplexml \
	php7-tokenizer \
	php7-xml \
	php7-xmlreader \
	php7-xmlrpc \
	php7-xmlwriter \
	php7-xsl \
	php7-zip \
	shadow \
	su-exec \
	tini \
	unit-php7 \
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
	/etc/php7/php.ini
RUN install -d -m 1777 /usr/tmp && \
	chmod 555 /sbin/docker-entrypoint.sh

EXPOSE 8080
WORKDIR /site

ENTRYPOINT ["/sbin/tini", "--", "/sbin/docker-entrypoint.sh"]
CMD ["app"]

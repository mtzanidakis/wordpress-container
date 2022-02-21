#!/bin/bash

set -e
umask 0022

# usage: convert_units 32M (or 32G)
# returns bytes
conv_bytes() {
	local _n=${1::-1}
	case $1 in
		*K) echo $(( ${_n} * 1024 )) ;;
		*M) echo $(( ${_n} * 1024 * 1024 )) ;;
		*G) echo $(( ${_n} * 1024 * 1024 * 1024 )) ;;
	esac
}

prepare_unit() {
	local _c=/var/lib/unit/conf.json
	local _t=${_c}.template
	[[ -f ${_c} ]] && return 0
	[[ -f ${_t} ]] || return 0

	echo "initializing unit config"
	local _postmax=${MAXUPLOAD:-32M}
	local _uploadmax=${_postmax}
	local _maxbody=$(conv_bytes ${_postmax})

	local _max=${PHPMAX:-20}
	local _spare=${PHPSPARE:-5}
	local _mem=${PHPMEMORY:-256M}
	local _exectime=${PHPEXECTIME:-60}
	sed     -e "s:__MAX_BODY_SIZE__:${_maxbody}:" \
		-e "s:__POST_MAX_SIZE__:${_postmax}:" \
		-e "s:__UPLOAD_MAX_FILESIZE__:${_uploadmax}:" \
		-e "s:__PHPMAX__:${_max}:" \
		-e "s:__PHPSPARE__:${_spare}:" \
		-e "s:__PHPMEMORY__:${_mem}:" \
		-e "s:__PHPEXECTIME__:${_exectime}:" \
		${_t} > ${_c}
}

prepare_msmtp() {
	local _defemail=wordpress@example.com
	if [[ $EMAIL_FROM ]]; then
		sed -i "s:${_defemail}:${EMAIL_FROM}:" /etc/msmtprc
	fi
}

_u=appuser
_g=${_u}
_w=/app

[[ $PGID ]] && groupmod -g $PGID ${_g}
[[ $PUID ]] && usermod -u $PUID ${_u}
chown -R appuser:appuser /home/appuser /site

case "$1" in
	app)
		prepare_msmtp
		prepare_unit
		exec /usr/sbin/unitd --no-daemon
		;;
	wp)
		shift
		exec su-exec ${_u} wp $@
		;;
	*) exec su-exec ${_u} $@ ;;
esac

#!/bin/bash

set -e
umask 0022

prepare_unit() {
	local _c=/var/lib/unit/conf.json
	local _t=${_c}.template
	[[ -f ${_c} ]] && return 0
	[[ -f ${_t} ]] || return 0

	echo "initializing unit config"
	local _max=${PHPMAX:-20}
	local _spare=${PHPSPARE:-5}
	local _mem=${PHPMEMORY:-256M}
	local _exectime=${PHPEXECTIME:-60}
	sed     -e "s:__PHPMAX__:${_max}:" \
		-e "s:__PHPSPARE__:${_spare}:" \
		-e "s:__PHPMEMORY__:${_mem}:" \
		-e "s:__PHPEXECTIME__:${_exectime}:" \
		${_t} > ${_c}
}

_u=appuser
_g=${_u}
_w=/app

[[ $PGID ]] && groupmod -g $PGID ${_g}
[[ $PUID ]] && usermod -u $PUID ${_u}
chown -R appuser:appuser /home/appuser

case "$1" in
	app)
		prepare_unit
		exec /usr/sbin/unitd --no-daemon
		;;
	wp)
		shift
		exec su-exec ${_u} wp $@
		;;
	*) exec su-exec ${_u} $@ ;;
esac

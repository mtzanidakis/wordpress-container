#!/bin/sh
set -e
[ "$1" ] || { echo "usage: apprun THE_ACTUAL_COMMAND"; exit 1; }
exec su-exec appuser $@

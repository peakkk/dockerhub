#!/bin/sh

set -e

if [ "$1" = '/bin/sh' ]; then
	python sqlmap.py -h | head -n 9
fi

exec $@
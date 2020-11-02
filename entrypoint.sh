#!/bin/sh
set -e
addgroup --system --gid $GID postfix
adduser --system --no-create-home --home /data --uid $UID --gid $GID --disabled-password --disabled-login postfix
addgroup --system --gid $GID_POSTDROP postdrop 

#check if config read/write
	#or else die

if [ ! -w "/config/" ]
then
	echo "Unable to read or write config directory!"
	return 1

elif [ ! -e /config/main.cf ] || [ ! -e /config/master.cf ]
then
	echo "Missing config files!"
fi

postfix set-permissions

exec /usr/sbin/postfix -c /config start-fg

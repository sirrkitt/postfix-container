#!/bin/sh

set -e

#check if config read/write
	#or else die
if [ ! -w "/config/" ]
then
	echo "Unable to read or write config directory!"
	return 1

elif [ "$INIT" == "YES" ]
then
	/bin/cp -R /etc/postfix/* /config/

elif [ ! -e /config/main.cf ] || [ ! -e /config/master.cf ]
then
	echo "Missing config files!"
fi

/bin/chown -R root:root /config

exec /usr/sbin/postfix -c /config start-fg

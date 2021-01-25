#!/bin/sh
set -e

addgroup -S -g $PGID postfix
adduser -S -H -h /spool -u $PUID -G postfix -D -s /sbin/nologin postfix
addgroup -S -g $PGID2 postdrop

#check if config read/write
	#or else die
if [ ! -w "/config/" ]
then
	echo "Unable to read or write config directory!"
	return 1

elif [ ! -e /config/main.cf ] || [ ! -e /config/master.cf ]
then
	echo "No configs found, populating with default"
	cp /etc/postfix/*.cf /config
fi

chown postfix /spool/* || true
chown postfix /data || true

chown root:postfix /spool/postfix/pid || true
chgrp postdrop /spool/maildrop || true 
chgrp postdrop /spool/public || true
postfix set-permissions || true

exec /usr/sbin/postfix -c /config start-fg

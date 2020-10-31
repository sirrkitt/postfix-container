#!/bin/sh
set -e
/usr/sbin/deluser postfix

/usr/sbin/deluser vmail
/usr/sbin/delgroup postdrop

/usr/sbin/addgroup -S -g $GID postfix
/usr/sbin/adduser -S -H -h /var/spool/postfix -G postfix -g postfix -u $UID postfix
/usr/sbin/addgroup postfix mail

/usr/sbin/addgroup -S -g $GID_POSTDROP postdrop
/usr/sbin/adduser -S -H -h /var/mail -s /sbin/nologin -G postdrop -u $UID_POSTDROP -g vmail vmail

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

/bin/chown root:root /socket
/bin/chown -R root:root /config /ssl
/bin/chown -R postfix:postdrop /data

exec /usr/sbin/postfix -c /config start-fg

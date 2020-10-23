#!/bin/sh
set -e
/usr/sbin/deluser postfix
/usr/sbin/delgroup postfix

/usr/sbin/delgroup postdrop
/usr/sbin/deluser vmail

/usr/sbin/addgroup -S -g $GUID postfix
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

/bin/chown -R root:root /config /socket /ssl
/bin/chown -R postfix:postfix /data
exec /usr/sbin/postfix -c /config start-fg

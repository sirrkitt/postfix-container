FROM alpine:3.13 as builder
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

ENV VERSION="3.6-20210110"

RUN	apk update --no-cache && apk add -U --no-cache \
		automake autoconf build-base libtool cyrus-sasl-dev linux-headers lmdb-dev m4 mariadb-connector-c-dev openldap-dev openssl-dev pcre-dev perl postgresql-dev sqlite-dev \
		db-dev libnsl-dev


#ADD	http://cdn.postfix.johnriley.me/mirrors/postfix-release/official/postfix-$VERSION.tar.gz	/usr/src/postfix.tar.gz
WORKDIR	/usr/src
ADD	http://cdn.postfix.johnriley.me/mirrors/postfix-release/experimental/postfix-$VERSION.tar.gz	/usr/src/postfix.tar.gz
RUN	tar xvf postfix.tar.gz

WORKDIR /usr/src/postfix-$VERSION

#RUN	make makefiles pie=yes shared=yes dynamicmaps=no \
RUN	make makefiles pie=yes shared=yes dynamicmaps=yes \
	meta_directory=/etc/postfix config_directory=/etc/postfix data_directory=/data queue_directory=/spool \
	DEBUG="" \
	manpage_directory=no \
	readme_directory=no \
	html_directory=no \
	AUXLIBS_LDAP="-lldap -llber" \
	AUXLIBS_MYSQL="$(mysql_config --libs)" \
	AUXLIBS_PCRE="$(pkg-config --libs libpcre)" \
	AUXLIBS_PGSQL="$(pkg-config --libs libpq)" \
	AUXLIBS_SQLITE="$(pkg-config --libs sqlite3)" \
	AUXLIBS_LMDB="$(pkg-config --libs lmdb)" \
	AUXLIBS="-L/usr/lib -lssl -lcrypto -lpthread -lsasl2 $LDFLAGS" \
	CCARGS='-I/usr/include \
		-DHAS_LDAP -DUSE_LDAP_SASL \
		-DHAS_LMDB -DDEF_DB_TYPE=\"lmdb\" $(pkg-config --cflags lmdb) \
		-DHAS_MYSQL $(mysql_config --include) -I/usr/include/mysql -I/usr/include/mysql/mariadb \
		-DHAS_PGSQL $(pkg-config --cflags libpq) \
		-DHAS_SQLITE $(pkg-config --cflags sqlite3) \
		-DUSE_TLS -I/usr/include/openssl \
		-DHAS_PCRE $(pkg-config --cflags libpcre) \
		-DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl \
		-DHAS_SHL_LOAD \
		-DDEF_SERVER_SASL_TYPE=\"dovecot\"' && \
	make -j32 && \
	make non-interactive-package install_root="/opt" manpage_directory="/usr/share/man"

FROM alpine:3.13
COPY --from=builder /opt /

ENV PUID=500
ENV PGID=500
ENV PGID2=990

COPY entrypoint.sh /entrypoint.sh
RUN	apk update --no-cache && apk add -U --no-cache coreutils cyrus-sasl-dev linux-headers lmdb-dev m4 mariadb-connector-c-dev openldap-dev openssl-dev pcre-dev perl postgresql-dev sqlite-dev libnsl db
RUN chmod a+x /entrypoint.sh

VOLUME [ "/config", "/data", "/ssl", "/socket", "/spool" ]

EXPOSE 25
EXPOSE 465
EXPOSE 587

ENTRYPOINT ["/entrypoint.sh"]

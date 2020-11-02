FROM ubuntu:groovy as builder
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

ENV VERSION="3.6-20201026"

RUN	apt update && apt install -y build-essential libicu67 libicu-dev m4 libdb-dev libldap2-dev libpcre3-dev libssl-dev libmariadb-dev libmariadb-dev-compat libsqlite3-dev libpq-dev liblmdb-dev pkg-config libsasl2-dev

WORKDIR	/usr/src
ADD	http://cdn.postfix.johnriley.me/mirrors/postfix-release/experimental/postfix-$VERSION.tar.gz	/usr/src/postfix.tar.gz
#ADD	http://cdn.postfix.johnriley.me/mirrors/postfix-release/official/postfix-$VERSION.tar.gz	/usr/src/postfix.tar.gz
RUN	tar xvf postfix.tar.gz

WORKDIR /usr/src/postfix-$VERSION
RUN	make makefiles pie=yes shared=yes dynamicmaps=no \
	meta_directory=/etc/postfix config_directory=/config data_directory=/data queue_directory=/spool \
	DEBUG="" \
	manpage_directory=no \
	readme_directory=no \
	html_directory=no \
	AUXLIBS_LDAP="-lldap -llber" \
	AUXLIBS_MYSQL="-lmysqlclient -lz -lm" \
	AUXLIBS_PCRE="-lpcre" \
	AUXLIBS_PGSQL="-lpq" \
	AUXLIBS_SQLITE="-lsqlite3" \
	AUXLIBS_LMDB="-llmdb" \
	AUXLIBS="-L/usr/lib -lssl -lcrypto -lpthread -lsasl2" \
	CCARGS='-I/usr/include \
		-DHAS_LDAP \
		-DHAS_LMDB -DDEF_DB_TYPE=\"lmdb\" \
		-DHAS_MYSQL -I/usr/include/mariadb -I/usr/include/mariadb/mysql \
		-DHAS_PGSQL -I/usr/include/postgresql \
		-DHAS_SQLITE \
		-DUSE_TLS -I/usr/include/openssl \
		-DHAS_PCRE -lpcre \
		-DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl \
		-DDEF_SERVER_SASL_TYPE=\"dovecot\"' && \
	make -j44 && \
	make non-interactive-package install_root="/opt" manpage_directory="/usr/share/man"

FROM ubuntu:groovy
COPY --from=builder /opt /

ENV UID=500
ENV GID=500
ENV GID_POSTDROP=990

COPY entrypoint.sh /entrypoint.sh
RUN apt update && apt install -y --no-install-recommends libsasl2-2 liblmdb0 libldap-2.4-2 libmariadb3 libpq5 libicu67 && apt autoclean && apt clean && rm -rf /var/lib/{apt,dpkg,cache,log}
RUN chmod a+x /entrypoint.sh && mv /config/* /etc/postfix/ && mkdir -p /config

VOLUME [ "/config", "/data", "/ssl", "/socket", "/spool" ]

EXPOSE 25
EXPOSE 465
EXPOSE 587

ENTRYPOINT ["/entrypoint.sh"]

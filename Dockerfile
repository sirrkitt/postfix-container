FROM alpine:3.11
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

ENV INIT="NO"

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

RUN apk update --no-cache && \
	apk add -U postfix postfix-ldap postfix-mysql postfix-pgsql postfix-sqlite

VOLUME [ "/config", "/spool", "/ssl"]
EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]

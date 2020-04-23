FROM alpine:3.11
LABEL maintainer="Jacob Louis Lemus Peschel <jacob@tlacuache.us>"

RUN apk update --no-cache && \
  apk add -U postfix postfix-ldap postfix-mysql postfix-pgsql postfix-sqlite

VOLUME [ "/config", "/spool", "/ssl" ]
EXPOSE 25

ENTRYPOINT ["/usr/sbin/postfix", "-c /config", "start-fg"]

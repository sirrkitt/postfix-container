FROM alpine:3.12
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

ENV INIT="NO"
ENV VERSION="3.5.7"

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

RUN apk update --no-cache && \
	apk add -U --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main postfix postfix-ldap postfix-mysql postfix-pgsql postfix-sqlite

VOLUME [ "/config", "/spool", "/ssl"]

EXPOSE 25
EXPOSE 465
EXPOSE 587

ENTRYPOINT ["/entrypoint.sh"]

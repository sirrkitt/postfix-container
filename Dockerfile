FROM alpine:3.12
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"

ENV INIT="NO"
ENV VERSION="3.5.7"

ENV UID=500
ENV GID=500

ENV UID_POSTDROP=990
ENV GID_POSTDROP=990

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

RUN apk update --no-cache && \
	apk add -U --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main postfix postfix-ldap postfix-mysql postfix-pgsql postfix-sqlite postfix-pcre ca-certificates && \
	chmod +x /entrypoint.sh

VOLUME [ "/config", "/data", "/ssl"]

EXPOSE 25
EXPOSE 465
EXPOSE 587

ENTRYPOINT ["/entrypoint.sh"]

FROM ghcr.io/linuxserver/baseimage-rdesktop-web:alpine

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AUDACITY_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl && \
 if [ -z ${AUDACITY_VERSION+x} ]; then \
	AUDACITY_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.13/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
	&& awk '/^P:audacity$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
 fi && \
 apk add --no-cache \
	audacity==${AUDACITY_VERSION} && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config

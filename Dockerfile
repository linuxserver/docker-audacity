FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AUDACITY_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y \
    libnss3 && \
  echo "**** install audacity ****" && \
  if [ -z ${AUDACITY_VERSION+x} ]; then \
    AUDACITY_VERSION=$(curl -sX GET "https://api.github.com/repos/audacity/audacity/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^Audacity-||'); \
  fi && \
  mkdir -p /app/audacity/ && \
  curl -o \
    /app/audacity/audacity -L \
    "https://github.com/audacity/audacity/releases/download/Audacity-${AUDACITY_VERSION}/audacity-linux-${AUDACITY_VERSION}-x86_64.AppImage" && \
  chmod +x /app/audacity/audacity && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config

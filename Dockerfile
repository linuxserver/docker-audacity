# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AUDACITY_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# title
ENV TITLE=Audacity

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    python3-xdg \
    libatk1.0 \
    libatk-bridge2.0 \
    libnss3 \
    libportaudio2 && \
  echo "**** install audacity ****" && \
  if [ -z ${AUDACITY_VERSION+x} ]; then \
    AUDACITY_VERSION=$(curl -sX GET "https://api.github.com/repos/audacity/audacity/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^Audacity-||'); \
  fi && \
  mkdir -p /app/audacity/ && \
  curl -o \
    /app/audacity/audacity -L \
    "https://github.com/audacity/audacity/releases/download/Audacity-${AUDACITY_VERSION}/audacity-linux-${AUDACITY_VERSION}-x64.AppImage" && \
  chmod +x /app/audacity/audacity && \
  ln -s \
    /usr/lib/x86_64-linux-gnu/libportaudio.so.2 \
    /usr/lib/x86_64-linux-gnu/libportaudio.so && \
  sed -i 's|</applications>|  <application title="Audacity" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
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

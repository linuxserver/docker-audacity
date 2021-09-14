FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal as buildstage

ARG AUDACITY_VERSION

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    cmake \
    curl \
    gcc \
    git \
    libasound2-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjack-jackd2-dev \
    python3-dev \
    python3-pip && \
  pip3 install -U pip && \
  pip install conan && \
  echo "**** build audacity ****" && \
  if [ -z ${AUDACITY_VERSION+x} ]; then \
    AUDACITY_VERSION=$(curl -sX GET "https://api.github.com/repos/audacity/audacity/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^Audacity-||'); \
  fi && \
  mkdir -p /app/audacity/build && \
  curl -o \
    /tmp/audacity.tar.gz -L \
    "https://github.com/audacity/audacity/archive/refs/tags/Audacity-${AUDACITY_VERSION}.tar.gz" && \
  tar xf \
    /tmp/audacity.tar.gz -C \
    /app/audacity --strip-components=1 && \
  cd /app/audacity/build && \
  cmake -DCMAKE_BUILD_TYPE=Release -Daudacity_use_wxwidgets=local -Daudacity_use_ffmpeg=loaded .. && \
  make -j2 && \
  make install && \
  echo "**** cleanup ****" && \
  apt-get purge --auto-remove -y \
	  build-essential \
    cmake \
    curl \
    gcc \
    git \
    libasound2-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjack-jackd2-dev && \
  mv /app/audacity/build/bin/Release/locale /app/ && \
  rm -rf /app/audacity


FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    libasound2 \
    libavformat58 \
    libgtk2.0-0 \
    libjack-jackd2-0 \
    python3-minimal && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /
COPY --from=buildstage /usr/local/share/audacity /usr/local/share/audacity
COPY --from=buildstage /usr/local/lib/audacity /usr/local/lib/audacity
COPY --from=buildstage /usr/local/bin/audacity /usr/local/bin/audacity
COPY --from=buildstage /app/locale /usr/local/share/locale

# ports and volumes
EXPOSE 3000
VOLUME /config

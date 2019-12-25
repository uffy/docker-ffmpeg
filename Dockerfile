FROM alpine:3.10

CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]
WORKDIR     /tmp/ffmpeg

ENV SOFTWARE_VERSION="4.2.1"
ENV SOFTWARE_VERSION_URL="http://ffmpeg.org/releases/ffmpeg-${SOFTWARE_VERSION}.tar.bz2"
ENV BIN="/usr/bin"

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
cd && \
apk update && \
apk upgrade && \
apk add \
  git \
  make \
  g++ \
  meson \
  pkgconfig \
  freetype-dev \
  gnutls-dev \
  lame-dev \
  libass-dev \
  libogg-dev \
  libtheora-dev \
  libvorbis-dev \
  libvpx-dev \
  libwebp-dev \
  libssh2 \
  opus-dev \
  rtmpdump-dev \
  x264-dev \
  x265-dev \
  yasm-dev \
  fdk-aac-dev && \
# add libvmaf
git clone --depth 1 https://github.com/Netflix/vmaf.git vmaf && \
cd vmaf && make && make install && cp -r /usr/local/include/libvmaf/* /usr/local/include && \
# vmaf end
apk add --no-cache --virtual \
  .build-dependencies \
  build-base \
  bzip2 \
  coreutils \
  gnutls \
  nasm \
  tar \
  x264 && \
DIR=$(mktemp -d) && \
cd "${DIR}" && \
wget "${SOFTWARE_VERSION_URL}" && \
tar xjvf "ffmpeg-${SOFTWARE_VERSION}.tar.bz2" && \
cd ffmpeg* && \
PATH="$BIN:$PATH" && \
./configure --help && \
./configure --bindir="$BIN" --disable-debug \
  --disable-shared \
  --disable-doc \
  --enable-static \
  --disable-ffplay \
  --enable-libzimg \
  --enable-ffprobe \
  --enable-avresample \
  --enable-libsvthevc \
  --enable-gnutls \
  --enable-gpl \
  --enable-libass \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-librtmp \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libvmaf \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree \
  --enable-postproc \
  --enable-small \
  --enable-version3 \
  --enable-libfdk-aac && \
make -j4 && \
make install && \
make distclean && \
rm -rf "${DIR}"  && \
apk del --purge .build-dependencies && \
rm -rf /var/cache/apk/*

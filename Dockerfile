############## build stage ##############
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy as buildstage

# install build packages
RUN \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	autoconf \
	automake \
	autopoint \
	binutils \
	cmake \
	curl \
	default-jre \
	g++ \
	gawk \
	gcc \
	git \
	gperf \
	libass-dev \
	libavahi-client-dev \
	libavahi-common-dev \
	libbluray-dev \
	libbz2-dev \
	libcurl4-openssl-dev \
	libegl1-mesa-dev \
	libflac-dev \
	libfmt-dev \
	libfreetype6-dev \
	libfstrcmp-dev \
	libgif-dev \
	libglew-dev \
	libiso9660-dev \
	libjpeg-dev \
	liblzo2-dev \
	libmicrohttpd-dev \
	libmysqlclient-dev \
	libnfs-dev \
	libpcre3-dev \
	libplist-dev \
	libsmbclient-dev \
	libsqlite3-dev \
	libssl-dev \
	libtag1-dev \
	libtiff5-dev \
	libtinyxml-dev \
	libtinyxml2-dev \
	libtool \
	libvorbis-dev \
	libxrandr-dev \
	libxslt-dev \
	make \
	nasm \
	python3-dev \
	rapidjson-dev \
	swig \
	uuid-dev \
	yasm \
	zip \
	zlib1g-dev \
	patch \
	libdrm-dev \
	libunistring-dev

# package source
ARG SOURCE="https://github.com/xbmc/xbmc/archive/21.0rc2-Omega.tar.gz"

# defines which addons to build
ARG KODI_ADDONS="vfs.libarchive vfs.rar vfs.sftp"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# fetch and extact source
RUN \
 set -ex && \
 mkdir -p \
	/tmp/kodi-source/build && \
 curl -o \
 /tmp/kodi.tar.gz -L "$SOURCE" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1

# copy and apply patches
COPY patches/ /patches/
RUN \
 cd /tmp/kodi-source && \
 git apply --ignore-whitespace /patches/*.patch

# build package
RUN \
 cd /tmp/kodi-source/build && \
 cmake ../. \
	-DCMAKE_INSTALL_LIBDIR=/usr/lib \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DAPP_RENDER_SYSTEM=gl \
	-DCORE_PLATFORM_NAME=x11 \
	-DENABLE_AIRTUNES=OFF \
	-DENABLE_ALSA=OFF \
	-DENABLE_AVAHI=OFF \
	-DENABLE_BLUETOOTH=OFF \
	-DENABLE_BLURAY=ON \
	-DENABLE_CAP=OFF \
	-DENABLE_CEC=OFF \
	-DENABLE_DBUS=OFF \
	-DENABLE_DVDCSS=OFF \
	-DENABLE_GLX=OFF \
	-DENABLE_INTERNAL_FLATBUFFERS=ON \
	-DENABLE_INTERNAL_FMT=ON \
	-DENABLE_INTERNAL_SPDLOG=ON \
	-DENABLE_INTERNAL_GTEST=ON \
	-DENABLE_LIBUSB=OFF \
	-DENABLE_NFS=ON \
	-DENABLE_OPTICAL=OFF \
	-DENABLE_PULSEAUDIO=OFF \
	-DENABLE_SNDIO=OFF \
	-DENABLE_UDEV=OFF \
	-DENABLE_UPNP=ON \
	-DENABLE_LCMS2=OFF \
	-DENABLE_EVENTCLIENTS=OFF \
	-DENABLE_LIRCCLIENT=OFF \
	-DENABLE_VAAPI=OFF \
	-DENABLE_VDPAU=OFF && \
 make -j2 && \
 make DESTDIR=/tmp/kodi-build install

# build kodi addons
RUN \
 set -ex && \
 cd /tmp/kodi-source && \
 make -j2 \
	-C tools/depends/target/binary-addons \
	ADDONS="$KODI_ADDONS" \
	PREFIX=/tmp/kodi-build/usr

# install kodi send
RUN \
 install -Dm755 \
	/tmp/kodi-source/tools/EventClients/Clients/KodiSend/kodi-send.py \
	/tmp/kodi-build/usr/bin/kodi-send && \
 install -Dm644 \
	/tmp/kodi-source/tools/EventClients/lib/python/xbmcclient.py \
	/tmp/kodi-build/usr/lib/python3.10/xbmcclient.py

############## runtime stage ##############
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="matthuisman.nz version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="matthuisman"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# install runtime packages
RUN \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	samba-common-bin \
	libass9 \
	libbluray2 \
	libegl1 \
	libfstrcmp0 \
	libgl1 \
	liblzo2-2 \
	libmicrohttpd12 \
	libmysqlclient21 \
	libnfs13 \
	libpcrecpp0v5 \
	libpython3.10 \
	python3-minimal \
	libsmbclient \
	libtag1v5 \
	libtinyxml2.6.2v5 \
	libtinyxml2-9 \
	libxrandr2 \
	libxslt1.1 \
	libplist3 \
	libdrm2 && \
	\
# cleanup
	\
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files and artifacts of build stages.
COPY root/ /
COPY --from=buildstage /tmp/kodi-build/usr/ /usr/

RUN chmod +x /usr/bin/install_addon

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9090 9777/udp

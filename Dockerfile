FROM lsiobase/alpine
MAINTAINER sparklyballs

# package version
ARG KODI_NAME=Jarvis
ARG KODI_VER=16.1

# environment settings
ENV HOME="/config"

# copy patches and excludes
COPY patches/ /patches/

# install build dependencies
RUN \
 apk add --no-cache --virtual=build-dependencies \
	afpfs-ng-dev \
	alsa-lib-dev \
	autoconf \
	automake \
	avahi-dev \
	bluez-dev \
	boost-dev \
	boost-thread \
	bsd-compat-headers \
	bzip2-dev \
	cmake \
	coreutils \
	curl \
	curl-dev \
	dbus-dev \
	eudev-dev \
	faac-dev \
	findutils \
	flac-dev \
	freetype-dev \
	fribidi-dev \
	g++ \
	gawk \
	gcc \
	gettext-dev \
	giflib-dev \
	git \
	glew-dev \
	glu-dev \
	gnutls-dev \
	gperf \
	hicolor-icon-theme \
	jasper-dev \
	lame-dev \
	libass-dev \
	libbluray-dev \
	libcap-dev \
	libcdio-dev \
	libcec-dev \
	libgcrypt-dev \
	libjpeg-turbo-dev \
	libmad-dev \
	libmicrohttpd-dev \
	libmodplug-dev \
	libmpeg2-dev \
	libnfs-dev \
	libogg-dev \
	libplist-dev \
	libpng-dev \
	libsamplerate-dev \
	libshairport-dev \
	libssh-dev \
	libtool \
	libva-dev \
	libvorbis-dev \
	libxmu-dev \
	libxrandr-dev \
	libxslt-dev \
	libxt-dev \
	lzo-dev \
	m4 \
	make \
	mariadb \
	mariadb-dev \
	mesa-demos \
	mesa-dev \
	nasm \
	openjdk7-jre-base \
	pcre-dev \
	py-bluez \
	py-pillow \
	py-simplejson \
	python \
	python-dev \
	rtmpdump-dev \
	samba-dev \
	sdl-dev \
	sdl_image-dev \
	sqlite-dev \
	swig \
	taglib-dev \
	tar \
	tiff-dev \
	tinyxml-dev \
	udisks2-dev \
	wget \
	x264-dev \
	x265-dev \
	xdpyinfo \
	yajl-dev \
	yasm-dev \
	zip && \

# fetch kodi source
 curl -o \
 /tmp/kodi.tar.gz -L \
	https://github.com/xbmc/xbmc/archive/$KODI_VER-$KODI_NAME.tar.gz && \
 mkdir -p \
	/tmp/kodi-source && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1 && \

# compile crossguid and libdcadec
 cd /tmp/kodi-source && \
	make -C tools/depends/target/crossguid PREFIX=/usr && \
	make -C tools/depends/target/libdcadec PREFIX=/usr && \

# apply patches
 git apply \
	/patches/"${KODI_NAME}"/fix-musl.patch && \
 git apply \
	/patches/"${KODI_NAME}"/fix-fileemu.patch && \
 git apply \
	/patches/"${KODI_NAME}"/fortify-source-fix.patch && \
 git apply \
	/patches/"${KODI_NAME}"/remove-filewrap.patch && \
 git apply \
	/patches/"${KODI_NAME}"/add-missing-includes.patch && \
 git apply \
	/patches/"${KODI_NAME}"/set-default-stacksize.patch && \
 git apply \
	/patches/"${KODI_NAME}"/headless.patch && \

# bootstrap and configure kodi
 MAKEFLAGS="-j1" ./bootstrap && \
	./configure \
		--build=$CBUILD \
		--disable-airplay \
		--disable-airtunes \
		--disable-alsa \
		--disable-asap-codec \
		--disable-avahi \
		--disable-dbus \
		--disable-debug \
		--disable-dvdcss \
		--disable-goom \
		--disable-joystick \
		--disable-libcap \
		--disable-libcec \
		--disable-libusb \
		--disable-non-free \
		--disable-openmax \
		--disable-optical-drive \
		--disable-projectm \
		--disable-pulse \
		--disable-rsxs \
		--disable-rtmp \
		--disable-spectrum \
		--disable-udev \
		--disable-vaapi \
		--disable-vdpau \
		--disable-vtbdecoder \
		--disable-waveform \
		--enable-libbluray \
		--enable-nfs \
		--enable-ssh \
		--enable-static=no \
		--enable-upnp \
		--host=$CHOST \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--prefix=/usr \
		--sysconfdir=/etc && \

# compile kodi
 make && \
 make install && \

# cleanup build dependencies
 apk del --purge \
	build-dependencies && \

# install runtime dependencies
 apk add --no-cache \
	curl \
	ffmpeg-libs \
	freetype \
	fribidi \
	glew \
	glu \
	jasper \
	libmicrohttpd \
	libpcrecpp \
	libpng \
	libsmbclient \
	libssh \
	libuuid \
	libxml2 \
	libxslt \
	lzo \
	mariadb-client-libs \
	mariadb-libs \
	py-bluez \
	python \
	taglib \
	tiff \
	tinyxml \
	wget \
	xrandr \
	yajl && \

# clean up
 rm -rf \
	/tmp/*

# copy local files for runtime
COPY root/ /

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9777/udp

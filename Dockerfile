FROM lsiobase/xenial
MAINTAINER sparklyballs

# package version
ARG KODI_NAME="Isengard"
ARG KODI_VER="15.2"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG KODI_ROOT="/tmp/source"
ARG KODI_SRC="${KODI_ROOT}/kodi"
ARG KODI_URL="https://github.com/xbmc/xbmc/archive"
ARG KODI_WWW="${KODI_URL}/${KODI_VER}-${KODI_NAME}.tar.gz"
ENV HOME="/config"

# copy patches and excludes
COPY patches/ /patches/
COPY excludes /etc/dpkg/dpkg.cfg.d/excludes

# build pack variable
ARG BUILD_LIST="\
	ant \
	autoconf \
	automake \
	autopoint \
	binutils \
	cmake \
	curl \
	default-jdk \
	doxygen \
	g++ \
	gawk \
	gcc \
	git-core \
	gperf \
	libass-dev \
	libavahi-client-dev \
	libbluray-dev \
	libboost1.58-dev \
	libbz2-ocaml-dev \
	libcap-dev \
	libcurl4-openssl-dev \
	libflac-dev \
	libfreetype6-dev \
	libgif-dev \
	libgle3-dev \
	libglew-dev \
	libgnutls-dev \
	libiso9660-dev \
	libjasper-dev \
	libjpeg-dev \
	liblzo2-dev \
	libmicrohttpd-dev \
	libmpeg2-4-dev \
	libmysqlclient-dev \
	libnfs-dev \
	libpcre3-dev \
	libsmbclient-dev \
	libsqlite3-dev \
	libssh-dev \
	libtag1-dev \
	libtiff5-dev \
	libtinyxml-dev \
	libtool \
	libvorbis-dev \
	libxml2-dev \
	libxrandr-dev \
	libxslt-dev \
	libyajl-dev \
	m4 \
	make \
	openjdk-8-jre-headless \
	python-dev \
	swig \
	uuid-dev \
	yasm \
	zip"

# install build packages
RUN \
 apt-get update && \
 apt-get install -y \
 	$BUILD_LIST && \

# fetch, unpack  and patch source
 mkdir -p \
	"${KODI_SRC}" && \
 curl -o \
 "${KODI_ROOT}/kodi.tar.gz" -L \
	"${KODI_WWW}" && \
 tar xf "${KODI_ROOT}/kodi.tar.gz" -C \
	"${KODI_SRC}" --strip-components=1 && \
 cd "${KODI_SRC}" && \
 git apply \
	/patches/"${KODI_NAME}"/headless.patch && \

# configure source
 ./bootstrap && \
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

# compile and install kodi
 make && \
 make install && \

# cleanup
 apt-get purge --remove -y \
	$BUILD_LIST && \
 apt-get autoremove -y && \
 apt-get autoclean -y && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# install runtime packages
RUN \
 apt-get update && \
 apt-get install -y \
 --no-install-recommends \
	libcurl3 \
	libfreetype6 \
	libfribidi0 \
	libglew1.13 \
	libjpeg8 \
	liblzo2-2 \
	libmicrohttpd10 \
	libmysqlclient20 \
	libnfs8 \
	libpcrecpp0v5 \
	libpython2.7 \
	libsmbclient \
	libssh-4 \
	libtag1v5 \
	libtinyxml2.6.2v5 \
	libvorbisenc2 \
	libxml2 \
	libxrandr2 \
	libxslt1.1 \
	libyajl2 && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9777/udp

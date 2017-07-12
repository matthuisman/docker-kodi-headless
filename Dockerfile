FROM lsiobase/xenial
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package version
ARG KODI_NAME="Krypton"
ARG KODI_VER="17.3"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# copy patches and excludes
COPY patches/ /patches/
COPY excludes /etc/dpkg/dpkg.cfg.d/excludes

# build packages variable
ARG BUILD_DEPENDENCIES="\
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
	libegl1-mesa-dev \
	libflac-dev \
	libfreetype6-dev \
	libgif-dev \
	libgle3-dev \
	libglew-dev \
	libgnutls-dev \
	libiso9660-dev \
	libjasper-dev \
	libjpeg-dev \
	liblcms2-dev \
	liblzo2-dev \
	libmicrohttpd-dev \
	libmpeg2-4-dev \
	libmysqlclient-dev \
	libnfs-dev \
	libpcre3-dev \
	libplist-dev \
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

# runtime packages variable
ARG RUNTIME_DEPENDENCIES="\
	libcdio13 \
	libcurl3 \
	libegl1-mesa \
	libfreetype6 \
	libfribidi0 \
	libglew1.13 \
	libjpeg8 \
	liblcms2-2 \
	liblzo2-2 \
	libmicrohttpd10 \
	libmysqlclient20 \
	libnfs8 \
	libpcrecpp0v5 \
	libplist3 \
	libpython2.7 \
	libsmbclient \
	libssh-4 \
	libtag1v5 \
	libtinyxml2.6.2v5 \
	libvorbisenc2 \
	libxml2 \
	libxrandr2 \
	libxslt1.1 \
	libyajl2"

# install build packages
RUN \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 828AB726 && \
 echo "deb http://ppa.launchpad.net/george-edison55/cmake-3.x/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/cmake.list && \
 echo "deb-src http://ppa.launchpad.net/george-edison55/cmake-3.x/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/cmake.list && \
 apt-get update && \
 apt-get install -y \
 	$BUILD_DEPENDENCIES && \

# fetch, unpack  and patch source
 mkdir -p \
	/tmp/kodi-source && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1 && \
 cd /tmp/kodi-source && \
 git apply \
	/patches/"${KODI_NAME}"/headless.patch && \

# configure source
 mkdir -p \
	/tmp/kodi-source/build && \
 cd /tmp/kodi-source/build && \
 cmake \
	../project/cmake/ \
		-DCMAKE_INSTALL_LIBDIR=/usr/lib \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DENABLE_AIRTUNES=OFF \
		-DENABLE_ALSA=OFF \
		-DENABLE_AVAHI=OFF \
		-DENABLE_BLUETOOTH=OFF \
		-DENABLE_BLURAY=ON \
		-DENABLE_CAP=OFF \
		-DENABLE_CEC=OFF \
		-DENABLE_DBUS=OFF \
		-DENABLE_DVDCSS=OFF \
		-DENABLE_LIBUSB=OFF \
		-DENABLE_NFS=ON \
		-DENABLE_NONFREE=OFF \
		-DENABLE_OPTICAL=OFF \
		-DENABLE_PULSEAUDIO=OFF \
		-DENABLE_SDL=OFF \
		-DENABLE_SSH=ON \
		-DENABLE_UDEV=OFF \
		-DENABLE_UPNP=ON \
		-DENABLE_VAAPI=OFF \
		-DENABLE_VDPAU=OFF && \

# compile and install kodi
 make && \
 make install && \

# install kodi-send
 install -Dm755 \
	/tmp/kodi-source/tools/EventClients/Clients/Kodi\ Send/kodi-send.py \
	/usr/bin/kodi-send && \
 install -Dm644 \
	/tmp/kodi-source/tools/EventClients/lib/python/xbmcclient.py \
	/usr/lib/python2.7/xbmcclient.py && \

# uninstall build packages
 apt-get purge -y --auto-remove \
	$BUILD_DEPENDENCIES && \

# install runtime packages
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	$RUNTIME_DEPENDENCIES && \

# cleanup
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

FROM lsiobase/ubuntu:bionic as buildstage
############## build stage ##############

# package versions
ARG KODI_NAME="Krypton"
ARG KODI_VER="17.6"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# copy patches and excludes
COPY patches/ /patches/
COPY excludes /etc/dpkg/dpkg.cfg.d/excludes

RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y \
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
	libavahi-core-dev\
	libbluray-dev \
	libboost1.65-dev \
	libbz2-ocaml-dev \
	libcap-dev \
	libcurl4-openssl-dev \
	libegl1-mesa-dev \
	libflac-dev \
	libfmt-dev \
	libfreetype6-dev \
	libgif-dev \
	libgle3-dev \
	libglew-dev \
	libiso9660-dev \
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
	libsndio-dev \
	libsqlite3-dev \
	libssh-dev \
	libtag1-dev \
	libtiff5-dev \
	libtinyxml-dev \
	libtool \
	libva-dev \
	libvdpau-dev \
	libvorbis-dev \
	libxml2-dev \
	libxrandr-dev \
	libxslt-dev \
	libyajl-dev \
	m4 \
	make \
	python-dev \
	rapidjson-dev \
	swig \
	uuid-dev \
	yasm \
	zip

RUN \
 echo "**** fetch source and apply any patches if required ****" && \
 mkdir -p \
	/tmp/kodi-source/build && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1 && \
 cd /tmp/kodi-source && \
 git apply \
	/patches/"${KODI_NAME}"/headless.patch

RUN \
 echo "**** compile kodi ****" && \
 cd /tmp/kodi-source/build && \
 cmake ../project/cmake/ \
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
 make && \
 make DESTDIR=/tmp/kodi-build install

RUN \
 echo "**** install kodi-send ****" && \
 install -Dm755 \
	/tmp/kodi-source/tools/EventClients/Clients/Kodi\ Send/kodi-send.py \
	/usr/bin/kodi-send && \
 install -Dm644 \
	/tmp/kodi-source/tools/EventClients/lib/python/xbmcclient.py \
	/usr/lib/python2.7/xbmcclient.py

############## runtime stage ##############
FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	libass9 \
	libbluray2 \
	libcurl4 \
	libegl1-mesa \
	libfreetype6 \
	libfribidi0 \
	libglew2.0 \
	liblcms2-2 \
	liblzo2-2 \
	libmicrohttpd12 \
	libmysqlclient20 \
	libpcrecpp0v5 \
	libpython2.7 \
	libsmbclient \
	libsndio6.1 \
	libssh-4 \
	libtag1v5 \
	libtinyxml2.6.2v5 \
	libva-drm2 \
	libva-x11-2 \
	libvdpau1 \
	libxml2 \
	libxrandr2 \
	libxslt1.1 \
	libyajl2 \
	python && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files and buildstage artifacts
COPY root/ /
COPY --from=buildstage /tmp/kodi-build/usr/ /usr/
COPY --from=buildstage /usr/bin/kodi-send /usr/bin/kodi-send
COPY --from=buildstage /usr/lib/python2.7/xbmcclient.py /usr/lib/python2.7/xbmcclient.py

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9090 9777/udp

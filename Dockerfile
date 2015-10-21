FROM linuxserver/baseimage.python
MAINTAINER Sparklyballs <sparklyballs@linuxserver.io>

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# set the initial install main version and root download path for kodi
ENV KODI_VER 15
ENV ROOT_PATH="https://files.linuxserver.io/kodi"

ENV APTLIST="gdebi-core wget"

# Set the locale
RUN locale-gen en_US.UTF-8

# install the packages required for kodi installation
RUN apt-get update && \
apt-get install \
$APTLIST -qy && \
apt-get clean -y && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# fetch kodi .deb and install it.
RUN wget -nd -nH -O /tmp/LATEST "$ROOT_PATH"/LATEST"$KODI_VER"  && \
LATEST=$(cat /tmp/LATEST) && \
wget -nd -nH -O /tmp/kodi-headless.deb  "$ROOT_PATH"/"$LATEST".deb && \
apt-get update -q && \
gdebi -n /tmp/kodi-headless.deb && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# adding custom files
ADD defaults/ /defaults/
ADD services/ /etc/service/
ADD init/ /etc/my_init.d/
RUN chmod -v +x /etc/service/*/run /etc/my_init.d/*.sh && \

# give user abc a home folder (needed for kodi to save files in /config/.kodi)
usermod -d /config abc

# set the volume and ports
VOLUME /config/.kodi
EXPOSE 8080 9777/udp



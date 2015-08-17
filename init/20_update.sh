#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
INSTALLED=`dpkg-query -W -f='${Version}' kodi-headless`

if [ -f "/tmp/LATEST" ]; then
rm /tmp/LATEST
fi

wget -nd -nH -P /tmp https://raw.githubusercontent.com/linuxserver/misc-files/master/kodi/LATEST
LATEST=$(cat /tmp/LATEST)
VERSION=$(sed 's/.*kodi-headless//' /tmp/LATEST | sed 's/amd64.deb//g' | sed 's/_//g')

if [ "$VERSION" == "$INSTALLED" ]; then
echo "No Update Required"
exit 0;
fi

if [ -f "/tmp/*.deb" ]; then
rm /tmp/*.deb
fi

apt-get remove --purge -y kodi-headless
wget -nd -nH -O /tmp/kodi-headless.deb  https://github.com/linuxserver/misc-files/blob/master/kodi/$LATEST?raw=true
apt-get update -qq
gdebi -n /tmp/kodi-headless.deb
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

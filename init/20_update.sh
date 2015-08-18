#!/bin/bash

# clean up any potential files in /tmp that may interfere with this script
if [ -f "/tmp/LATEST" ]; then
rm /tmp/LATEST
fi
if [ -f "/tmp/"*.deb ]; then
rm /tmp/*.deb
fi
if [ -f "/tmp/warn.nfo" ]; then
rm /tmp/warn.nfo
fi

# set what to display if we are going to upgrade/downgrade main version
WARN_SET='/tmp/warn.nfo'
cat > $WARN_SET <<-WARNSIGN
##########################################################################
# You have set the version variable to a different main version than is  #
# locally installed, this script will downgrade/upgrade to the version   #
# you have chosen, make sure you have set the variable correctly and all #
# your local kodi installs are at the same main version if you want to   #
# share libraries with them.                                             #
##########################################################################
WARNSIGN


# check what version we currently have installed
INSTALLED=`dpkg-query -W -f='${Version}' kodi-headless`


FETCH_VER=${INSTALLED%.*}


# get file containing latest build of our chosen main version
wget -nd -nH -O /tmp/LATEST https://raw.githubusercontent.com/linuxserver/misc-files/master/kodi/LATEST$FETCH_VER
LATEST=$(cat /tmp/LATEST)
VERSION=$(sed 's/.*kodi-headless//' /tmp/LATEST | sed 's/amd64.deb//g' | sed 's/_//g')

# decide if we need to update local version, if not exit from script gracefully
if [ "$VERSION" == "$INSTALLED" ]; then
echo "No Update Required"
exit 0;
fi

# install latest build of our chosen main version
apt-get remove --purge -y kodi-headless
wget -nd -nH -O /tmp/kodi-headless.deb  https://github.com/linuxserver/misc-files/blob/master/kodi/$LATEST?raw=true
apt-get update -qq
gdebi -n /tmp/kodi-headless.deb
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

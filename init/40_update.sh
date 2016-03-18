#!/bin/bash

# opt out for autoupdates
[ "$ADVANCED_DISABLEUPDATES" ] && exit 0

# clean up any potential files in /tmp that may interfere with execution of this script
rm -rf /tmp/*

# check what version we currently have installed
INSTALLED=$(dpkg-query -W -f='${Version}' kodi-headless)

# if $VERSION is set, strip any whitespace and everything after any "."
if [ -n "$VERSION" ]; then
SANEDVERSION0="$VERSION"
SANEDVERSION1="${SANEDVERSION0#"${SANEDVERSION0%%[![:space:]]*}"}"
SANEDVERSION="${SANEDVERSION1%"${SANEDVERSION1##*[![:space:]]}"}"
FETCH_VER="${SANEDVERSION%%\.*}"
else
FETCH_VER="${INSTALLED%%\.*}"
fi

# check VERSION is in range.
if ((FETCH_VER < OLDEST_VERSION)) || ((FETCH_VER > CURR_LATEST)); then
echo "Version not available , keeping currently installed version"
FETCH_VER="${INSTALLED%%\.*}"
fi


# set what to display if we are going to upgrade/downgrade main version
WARN_SET='/tmp/warn.nfo'
cat > $WARN_SET <<-WARNSIGN
##########################################################################
# You set the VERSION variable to a different main version no. than was  #
# locally installed, this script downgraded/upgraded kodi version to     #
# what you chose, make sure you have set the variable correctly and all  #
# your local kodi installs are at the same main version if you want to   #
# share libraries with them.                                             #
##########################################################################
WARNSIGN

# get file with informaton on latest build of our chosen main version
wget -nd -nH -O /tmp/LATEST "$ROOT_PATH"/LATEST"$FETCH_VER"
LATEST=$(cat /tmp/LATEST)
REMOTE_VERSION=$(sed 's/.*kodi-headless//' /tmp/LATEST | sed 's/amd64//g' | sed 's/_//g')

# decide if we need to update local version, if not exit from script gracefully
if [ "$REMOTE_VERSION" == "$INSTALLED" ]; then
echo "No Update Required"
exit 0;
fi

# fetch latest build and checksum it, if checksum fails then keep current version
wget -nd -nH -O /tmp/kodi-headless.md5 "$ROOT_PATH"/"$LATEST".md5
wget -nd -nH -O /tmp/kodi-headless.deb "$ROOT_PATH"/"$LATEST".deb

cd /tmp || exit
CHECK_PASS=$(md5sum -c kodi-headless.md5)
if [ "$CHECK_PASS" = "kodi-headless.deb: OK" ]; then
echo "Checksum Passed"
else
echo "Checksum Failed, falling back to original version , try again by restarting the container"
exit 0;
fi

# if checksum passed, install latest build of our chosen main version
cd / || exit
apt-get remove --purge -y kodi-headless
apt-get update -qq
gdebi -n /tmp/kodi-headless.deb
apt-get autoremove -y

# display warning about version change
if [ "$FETCH_VER" -ne "${INSTALLED%.*}" ]; then
less /tmp/warn.nfo
sleep 5s
fi
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

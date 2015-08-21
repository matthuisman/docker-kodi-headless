![http://linuxserver.io](http://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](http://linuxserver.io) team brings you another quality container release featuring auto-update on startup, easy user mapping and community support. Be sure to checkout our [forums](http://forum.linuxserver.io) or for real-time support our [IRC](http://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`.

# linuxserver/kodi-headless

A headless install of kodi in a docker format, most useful for a mysql setup of kodi to allow library updates to be sent without the need for a player system to be permantely on. You can choose between (at the time of writing) 2 main versions of kodi. 14 helix and 15 isengard.

## Usage

```
docker create --name=<container-name> -v /etc/localtime:/etc/localtime:ro -v <path to data>:/config -e PGID=<gid> -e PUID=<uid> -e VERSION=<version>  -p 8080:8080 -p 9777:9777 linuxserver/kodi-headless
```

**Parameters**

* `-p 8080` - webui port
* `-p 9777` - esall interface port
* `-v /etc/localhost` for timesync - *optional*
* `-v /config` -
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e VERSION` - Main version of kodi - see below for explanation

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it kodi-headless /bin/bash`.

### User / Group Identifiers

**TL;DR** - The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).

Part of what makes our containers work so well is by allowing you to specify your own `PUID` and `PGID`. This avoids nasty permissions errors with relation to data volumes (`-v` flags). When an application is installed on the host OS it is normally added to the common group called users, Docker apps due to the nature of the technology can't be added to this group. So we added this feature to let you easily choose when running your containers.

## Setting up the application 

<Insert a basic user guide here to get a n00b up and running with the software inside the container.> DELETE ME


## Updates

* Upgrade to the latest version simply `docker restart kodi-headless`.
* To monitor the logs of the container in realtime `docker logs -f kodi-headless`.

## Credits
Various members of the xbmc/kodi community for patches and advice.

## Versions

+ **21.08.2015:** Initial Release. 


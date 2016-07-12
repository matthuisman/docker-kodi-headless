![https://linuxserver.io](https://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io](https://forum.linuxserver.io)
* [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`
* [Podcast](https://www.linuxserver.io/index.php/category/podcast/) covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/kodi-headless

A headless install of kodi isengard (v15) in a docker format, most useful for a mysql setup of kodi to allow library updates to be sent without the need for a player system to be permanently on. You can choose between (at the time of writing),using tags, 3 main versions of kodi. 14 helix, 15 isengard and 16 jarvis.

## Usage

```
docker create --name=kodi-headless \
-v <path to data>:/config/.kodi \
-e PGID=<gid> -e PUID=<uid> \
-e TZ=<timezone> \
-p 8080:8080 -p 9777:9777/udp \
linuxserver/kodi-headless:jarvis
```

**Parameters**

* `-p 8080` - webui port
* `-p 9777/udp` - esall interface port
* `-v /config/.kodi` - path for kodi configuration files
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` - for timezone information *eg Europe/London, etc*

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```    

## Setting up the application

Mysql/mariadb settings are entered by editing the file advancedsettings.xml which is found in the userdata folder of your /config/.kodi mapping. Many other settings are within this file also.

The default user/password for the web interface and for apps like couchpotato etc to send updates is xbmc/xbmc.  

If you intend to use this kodi instance to perform library tasks other than merely updating, eg. library cleaning etc, it is important to copy over the sources.xml from the host machine that you performed the initial library scan on to the userdata folder of this instance, otherwise database loss can and most likely will occur.

## Info

* Shell access whilst the container is running: `docker exec -it kodi-headless /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f kodi-headless`

## Credits
Various members of the xbmc/kodi community for patches and advice.

## Versions
+ **12.07.16:** Rebase to xenial, split versions into separate tags.
+ **13.03.16:** Make kodi 16 (jarvis) default installed version.
+ **21.08.15:** Initial Release.


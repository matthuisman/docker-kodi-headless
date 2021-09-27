# matthuisman/kodi-headless
A headless install of kodi in a docker container, most useful for a mysql setup of kodi to allow library updates to be sent without the need for a player system to be permanently on.

https://hub.docker.com/r/matthuisman/kodi-headless

## Usage

```
sudo docker run -d \
--name=kodi-headless \
--restart unless-stopped \
-v <path to data>:/config/.kodi \
-e PGID=<gid> -e PUID=<uid> \
-e TZ=<timezone> \
-p 8080:8080 \
-p 9090:9090 \
-p 9777:9777/udp \
matthuisman/kodi-headless:Leia
```
**Parameters**

* `-p 8080` - webui port
* `-p 9090` - websockets port
* `-p 9777/udp` - esall interface port
* `-v /config/.kodi` - path for kodi configuration files
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` - for timezone information *eg Europe/London, etc*

#### Tags
+ Leia
+ Matrix

#### Platforms
+ amd64
+ armv6 / armv7
+ armv8 / arm64

Docker will automatically pull the correct version for your platform 

## User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

SQL settings are entered by editing the file advancedsettings.xml which is found in the userdata folder of your /config/.kodi mapping. 
Many other settings are within this file also.

The default user/password for the web interface is kodi/kodi.

If you intend to use this kodi instance to perform library tasks other than merely updating, eg. library cleaning etc, it is important to copy over the sources.xml from the host machine that you performed the initial library scan on to the userdata folder of this instance, otherwise database loss can and most likely will occur.

## Info

* Shell access whilst the container is running: `docker exec -it kodi-headless /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f kodi-headless`

## Credits

+ [linuxserver](https://github.com/linuxserver/docker-kodi-headless/) (original headless container)

## Versions

+ **05.11.20:** Bump Leia to 18.9

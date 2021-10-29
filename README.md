# matthuisman/kodi-headless
A headless install of kodi in a docker container.
Commonly used with MySQL Kodi setup to allow library updates via web interface.

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
matthuisman/kodi-headless:Matrix
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

If you intend to use this kodi instance to perform library tasks other than merely updating, eg. library cleaning etc, it is important to copy over the sources.xml from the host machine that you performed the initial library scan on to the userdata folder of this instance, otherwise database loss can and most likely will occur.

## Info

* Shell access whilst the container is running: `docker exec -it kodi-headless /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f kodi-headless`

## Credits

+ [linuxserver](https://github.com/linuxserver/docker-kodi-headless/) (original headless container)

## Fast Scanning
The below works if your media is stored on the same machine as this docker container and your using smb:// to share that media on the network.

First, mount your host media directory somewhere inside the container so Kodi can see it.  
eg. ```--mount type=bind,source=/sharedfolders/pool,target=/media```

Now, the below magic is done in Kodis advancedsettings.xml
```
<pathsubstitution>
  <substitute>
    <from>smb://192.168.20.3/sharedfolders/pool/</from>
    <to>/media/</to>
  </substitute>
</pathsubstitution>
```

That's it. 
Now instead of always needing to scan over smb://, it will replace that with /media and scan much quicker.
When it does find new items, they are correctly stored in the SQL using their smb:// path

## Versions

+ **29.10.21:** Bump Matrix to 19.3
+ **10.10.21:** Bump Matrix to 19.2

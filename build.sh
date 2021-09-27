docker login
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multiarch --driver docker-container --use
docker buildx build --push --platform linux/amd64 --tag matthuisman/kodi-headless:Leia-amd64 --pull .
docker buildx build --push --platform linux/arm64/v8 --tag matthuisman/kodi-headless:Leia-arm64 --pull .
docker buildx build --push --platform linux/arm/v6 --tag matthuisman/kodi-headless:Leia-arm --pull -f Dockerfile.arm .
docker manifest create matthuisman/kodi-headless:Leia matthuisman/kodi-headless:Leia-arm matthuisman/kodi-headless:Leia-amd64 matthuisman/kodi-headless:Leia-arm64
docker manifest push --purge matthuisman/kodi-headless:Leia

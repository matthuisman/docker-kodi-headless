docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multiarch --driver docker-container --use
docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag matthuisman/kodi-headless:Matrix --pull --no-cache .

## LA DOCKER on UBUNTU 4 CPU

# git clone https://github.com/matthuisman/docker-kodi-headless
# cd docker-kodi-headless
# git checkout Nexus
# chmod +x build.sh

# docker login
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx create --name multiarch --driver docker-container --use

docker buildx build --push --pull --progress plain --platform linux/amd64 --tag matthuisman/kodi-headless:Piers-amd64 . && \
docker buildx build --push --pull --progress plain --platform linux/arm64/v8 --tag matthuisman/kodi-headless:Piers-arm64 . && \
docker buildx build --push --pull --progress plain --platform linux/arm/v7 --tag matthuisman/kodi-headless:Piers-arm -f Dockerfile.arm . && \
docker manifest create matthuisman/kodi-headless:matthuisman/kodi-headless:Piers-amd64 matthuisman/kodi-headless:Piers-arm64 matthuisman/kodi-headless:Piers-arm && \
docker manifest push --purge matthuisman/kodi-headless:Piers
echo "DONE!"

# nohup ./build.sh &
# tail -f nohup.out

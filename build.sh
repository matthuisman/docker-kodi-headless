## LA DOCKER on UBUNTU 4 CPU

# git clone https://github.com/matthuisman/docker-kodi-headless
# cd docker-kodi-headless
# git checkout Matrix
# chmod +x build.sh

# docker login
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx create --name multiarch --driver docker-container --use

docker buildx build --push --pull --progress plain --platform linux/amd64 --tag matthuisman/kodi-headless:Matrix-amd64 . && \
docker buildx build --push --pull --progress plain --platform linux/arm64/v8 --tag matthuisman/kodi-headless:Matrix-arm64 . && \
docker buildx build --push --pull --progress plain --platform linux/arm/v7 --tag matthuisman/kodi-headless:Matrix-arm -f Dockerfile.arm . && \
docker manifest create matthuisman/kodi-headless:matthuisman/kodi-headless:Matrix-amd64 matthuisman/kodi-headless:Matrix-arm64 Matrix matthuisman/kodi-headless:Matrix-arm && \
docker manifest push --purge matthuisman/kodi-headless:Matrix
echo "DONE!"

# nohup ./build.sh &
# tail -f nohup.out

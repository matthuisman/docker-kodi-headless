docker buildx create --use --name builder
docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag matthuisman/kodi-headless:Matrix .

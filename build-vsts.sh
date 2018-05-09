#!/usr/bin/env bash
set -x -e

REGISTRY=nbcwebcontainers.azurecr.io
NAME=appservice-drupal-varnish
VERSION=4.1

buildnumber=${4-$(date -u +"%Y%m%d")}
docker build \
  -t "${REGISTRY}/${NAME}:${VERSION}_${buildnumber}" -t "${REGISTRY}/${NAME}:${VERSION}" -t "${REGISTRY}/${NAME}:latest" \
  .

# build runner must define LOGIN_NAME and LOGIN_KEY
docker login $REGISTRY -u $LOGIN_NAME -p $LOGIN_KEY

docker push "${REGISTRY}/${NAME}:${VERSION}_${buildnumber}"
docker push "${REGISTRY}/${NAME}:${VERSION}"
docker push "${REGISTRY}/${NAME}:latest"

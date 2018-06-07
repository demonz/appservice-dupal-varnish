#!/usr/bin/env bash
set -x -e


# import variables
REGISTRY=demonz
NAME=appservice-drupal-varnish
VERSION=7.x-4.1


docker pull wodby/drupal-varnish:4.1


docker build \
  -t "${REGISTRY}/${NAME}:${VERSION}" -t "${REGISTRY}/${NAME}:latest" \
  .

#!/usr/bin/env bash
set -x -e

NAME="${1:-appservice-drupal-varnish}"
VERSION="${2:-4.1}"

../build.sh $NAME $VERSION

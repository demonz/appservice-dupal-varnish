./build.sh 1

# import variables
REGISTRY=demonz
NAME=appservice-drupal-varnish
VERSION=7.x-4.1


set -ex
docker push ${REGISTRY}/${NAME}:${VERSION}

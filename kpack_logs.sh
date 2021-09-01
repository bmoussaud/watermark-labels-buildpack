#!/usr/bin/env bash
#set -x

IMAGE=$1
NAMESPACE=$2

POD=$(kubectl -n ${NAMESPACE} get image ${IMAGE} -o jsonpath="{.status.latestBuildRef}")
echo "${POD}"
CONTAINERS=$(kubectl -n ${NAMESPACE} get pod ${POD}-build-pod -o jsonpath="{.spec['initContainers'][*].name}")
echo ${CONTAINERS}

export IFS=" "
for container in $CONTAINERS; do
  echo "==> $container"
  kubectl logs ${POD}-build-pod  -n ${NAMESPACE} -c $container
  echo "------"
done


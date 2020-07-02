#!/bin/bash
echo "cleanDockerSome.sh started..."

output1=$(docker ps | grep "apt-cacher-ng" | awk '{ print $1 }')

docker stop $(docker ps -aq | grep -v $output1)
docker rm $(docker ps -aq | grep -v $output1)
docker image prune -a -f

echo "cleanDockerSome.sh completed."

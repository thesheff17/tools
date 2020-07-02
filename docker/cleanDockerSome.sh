#!/bin/bash
echo "cleanDockerSome.sh started..."

output1=$(docker ps | grep "apt-cacher-ng" | awk '{ print $1 }')
output2=$(docker images | grep "apt-cacher-ng" | awk '{ print $3 }')
output3=$(docker images | grep "ubuntu                       20.04" | awk '{ print $3 }')

docker stop $(docker ps -aq | grep -v $output1)
docker rm $(docker ps -aq | grep -v $output1)
docker rmi $(docker images -q | grep -v $output2 | grep -v $output3)

echo "cleanDockerSome.sh completed."

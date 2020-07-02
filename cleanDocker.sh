#!/bin/bash
echo "cleanDocker.sh started..."

docker stop $(docker ps -aq)
docker rm $(docker ps -a -q)
docker rmi -f $(docker images -q)

echo "cleanDocker.sh completed."

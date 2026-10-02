#!/bin/bash
#set -x
# Stop and remove all Docker containers
if [ "$(docker ps -aq | wc -l)" -eq "0" ]; then
  echo "No containers to stop or remove."
  exit 0
fi
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

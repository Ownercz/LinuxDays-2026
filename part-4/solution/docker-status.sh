#!/bin/bash
#set -x
if [ "$(docker ps -aq | wc -l)" -eq "0" ]; then
  echo "No containers found."
  exit 0
fi
docker ps

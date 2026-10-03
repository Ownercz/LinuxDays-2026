#!/bin/bash
set -x
ansible -i inventory/workshop.ini all -m ping

ansible -i inventory/workshop.ini all -m shell -a uptime

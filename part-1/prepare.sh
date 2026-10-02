#!/bin/bash
set -x
ansible-playbook -i inventory/workshop.ini -D -v prepare.yml


#!/bin/bash
set -x
ansible -i inventory/workshop.ini all -m ping

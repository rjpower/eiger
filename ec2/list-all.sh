#!/bin/bash

# list all instances, with their name, public and private ips

source $(dirname $0)/ec2-utils.sh

for r in $REGIONS; do
  list_all $r &
done

wait

#!/bin/bash

source ec2-utils.sh

for r in $REGIONS; do
  get_public_ips $r | xargs -n1
done

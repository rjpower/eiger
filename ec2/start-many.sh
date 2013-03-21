#!/bin/bash

source $(dirname $0)/ec2-utils.sh

for r in $REGIONS; do
  ($(dirname $0)/start-instances.sh $1 $2 $r) &
done

wait
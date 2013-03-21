#!/bin/bash

source $(dirname $0)/ec2-utils.sh

name=$1
[[ -n $name ]] || abort "Specify name of servers to stop"

for r in $REGIONS; do
  ($(dirname $0)/stop-instances.sh $1 $r) &
done

wait

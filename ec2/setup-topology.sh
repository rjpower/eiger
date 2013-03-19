#!/bin/bash

source $(dirname $0)/ec2-utils.sh

cp conf/cassandra-topology.TEMPLATE conf/cassandra-topology.properties
DC=1
for r in $REGIONS; do
  hosts="$(get_public_ips $r) $(get_private_ips $r)"
  echo $hosts | xargs -n1 | awk "{print \$1\"=DC$DC:RAC1\"}" >> conf/cassandra-topology.properties
  DC=$((DC + 1))
done


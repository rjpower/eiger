#!/bin/bash

source $(dirname $0)/ec2-utils.sh

cp conf/cassandra-topology.TEMPLATE conf/cassandra-topology.properties
for r in $REGIONS; do 
  (list_all $r) &
done
wait

DC=1
for r in $REGIONS; do  
  grep $SERVER_TAG ./ec2-info.$r | awk "{print \$3\"=DC$DC:RAC1\"; print \$4\"=DC$DC:RAC1\"}" >> conf/cassandra-topology.properties
  DC=$((DC + 1))
done

#!/bin/bash

set -x

source ec2-utils.sh

PUBLIC=$(get_public_ips)
PRIVATE=$(get_private_ips)
HOSTS="$PUBLIC $PRIVATE"

echo $HOSTS | xargs -n1 > current-host-list

cp conf/cassandra-topology.TEMPLATE conf/cassandra-topology.properties

echo $HOSTS | xargs -n1 | awk '{print $1"=DC1:RAC1"}' >> conf/cassandra-topology.properties


#!/bin/bash

HOSTS=$(ec2-describe-instances | grep INSTANCE | awk '{print $14'})
cp conf/cassandra-topology.TEMPLATE  conf/cassandra-topology.properties

echo $HOSTS | xargs -n1 | awk '{print $1"=DC1:RAC1"}' >> conf/cassandra-topology.properties
SEED=$(echo $HOSTS | xargs -n1 | tail -n1)
sed  -e "s/SEED_HOST/$SEED/" conf/cassandra.yaml.TEMPLATE  > conf/cassandra.yaml


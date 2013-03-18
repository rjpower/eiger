#!/bin/bash

SEED=$(cat current-host-list | tail -n1)
PUBLIC=$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)
PRIVATE=$(wget -qO- http://instance-data/latest/meta-data/local-ipv4)

echo Public ip: $PUBLIC, private ip: $PRIVATE

cp -rv conf /tmp/cassandra-local-conf 

cat conf/cassandra.yaml.TEMPLATE |
  sed -e "s/PUBLIC_ADDRESS/$PUBLIC/g" |
  sed -e "s/PRIVATE_ADDRESS/$PRIVATE/g" |
  sed -e "s/SEED_HOST/$SEED/g" > /tmp/cassandra-local-conf/cassandra.yaml 

bin/cassandra -Dcassandra.config=file:///tmp/cassandra-local-conf/cassandra.yaml $*

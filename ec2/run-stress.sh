#!/bin/bash

source $(dirname $0)/ec2-utils.sh

PUBLIC=$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)
PRIVATE=$(wget -qO- http://instance-data/latest/meta-data/local-ipv4)

#OFFSET=$(cat ec2-info* | grep $SERVER_TAG | grep -n $PUBLIC | awk -F: '{print $1}')
#OFFSET=$((OFFSET - 1))

OFFSET=0

TOTAL=$(cat ec2-info* | grep $SERVER_TAG | wc -l)

DC_NODES=

# find the number of datacenters we have
num_dcs=0
for r in $REGIONS; do
  if (grep $SERVER_TAG ec2-info.$r); then
    num_dcs=$((num_dcs + 1))
  fi
done

#find the datacenter we're in, AND MANUALLY BUILD TH ELIST OF HOSTS
# because, heaven forbid we ask our server for it.
for dc in $(seq 0 10); do 
  if (cat conf/cassandra-topology.properties | grep "DC$dc" | grep $PUBLIC); then
    echo My DC: $dc
    DC_NODES=$(cat conf/cassandra-topology.properties | grep "DC$dc" | awk -F= '{printf($1 ",")}')
  fi
done 

[[ -n $DC_NODES ]] || abort "No nodes for my datacenter?"

strategy_properties="DC0:1"
for i in $(seq 1 $((num_dcs-1))); do
  strategy_properties=$(echo ${strategy_properties}",DC${i}:1")
done

echo My offset: $OFFSET, total client: $TOTAL, strategy: $strategy_properties, nodes: $DC_NODES

DIRNAME=$(readlink -f .)
rsync -e 'ssh -oStrictHostKeyChecking=no' -aip nfs.rjpower.org:$DIRNAME /tmp/
(
  cd /tmp/eiger/tools/stress/
  set -x
  bin/stress \
  --nodes=$DC_NODES \
  --stress-index=$OFFSET \
  --stress-count=$TOTAL \
  --replication-strategy=NetworkTopologyStrategy \
  --consistency-level=LOCAL_QUORUM \
  --strategy-properties=$strategy_properties \
  $*
)

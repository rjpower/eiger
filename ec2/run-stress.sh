#!/bin/bash

source $(dirname $0)/ec2-utils.sh

PUBLIC=$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)
PRIVATE=$(wget -qO- http://instance-data/latest/meta-data/local-ipv4)

OFFSET=$(cat ec2-info* | grep $SERVER_TAG | grep -n $PUBLIC | awk -F: '{print $1}')
OFFSET=$((OFFSET - 1))

TOTAL=$(cat ec2-info* | grep $SERVER_TAG | wc -l)

num_dcs=0
for r in $REGIONS; do
  if (grep $SERVER_TAG ec2-info.$r); then
    num_dcs=$((num_dcs + 1))
  fi
done
 
strategy_properties="DC0:1"
for i in $(seq 1 $((num_dcs-1))); do
  strategy_properties=$(echo ${strategy_properties}",DC${i}:1")
done

echo My offset: $OFFSET, total client: $TOTAL, strategy: $strategy_properties

exit

DIRNAME=$(readlink -f .)
rsync -e 'ssh -oStrictHostKeyChecking=no' -aip nfs.rjpower.org:$DIRNAME /tmp/
(
  cd /tmp/eiger/tools/stress/
  ant
  bin/stress \
  --nodes=localhost \
  --stress-index=$OFFSET \
  --stress-count=$TOTAL \
  --replication-strategy=NetworkTopologyStrategy \
  --strategy-properties=$strategy_properties \
  $*
)

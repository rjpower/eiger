#!/bin/bash

source $(dirname $0)/ec2-utils.sh

PUBLIC=$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)
PRIVATE=$(wget -qO- http://instance-data/latest/meta-data/local-ipv4)

OFFSET=$(cat ec2-info* | grep $SERVER_TAG | grep -n $PUBLIC | awk -F: '{print $1}')
OFFSET=$((OFFSET - 1))

TOTAL=$(cat ec2-info* | grep $SERVER_TAG | wc -l)

echo My offset: $OFFSET, total client: $TOTAL

exit

DIRNAME=$(readlink -f .)
rsync -e 'ssh -oStrictHostKeyChecking=no' -aip nfs.rjpower.org:$DIRNAME /tmp/
(
  cd /tmp/eiger/tools/stress/
  bin/stress --nodes=localhost --stress-index=$OFFSET --stress-count=$TOTAL $*
)

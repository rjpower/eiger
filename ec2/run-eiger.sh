#!/bin/bash

source $(dirname $0)/ec2-utils.sh

# setup-topology must have been run before running this!
TMP=$(cat ec2-info.*)
[[ -n $TMP ]] || abort "Setup topology has not been run."

# the first server in our list is the seed.
SEEDS=$(cat ec2-info.* | grep $SERVER_TAG | head -n1 | awk '{printf("        - seeds: " $4 "\\n")}')
PUBLIC=$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)
PRIVATE=$(wget -qO- http://instance-data/latest/meta-data/local-ipv4)

echo Public ip: $PUBLIC, private ip: $PRIVATE

DIRNAME=$(readlink -f .)

rsync -e 'ssh -oStrictHostKeyChecking=no' -aip nfs.rjpower.org:$DIRNAME /tmp/
(
  cd /tmp/eiger
  cat conf/cassandra.yaml.TEMPLATE |
    sed -e "s/PUBLIC_ADDRESS/$PUBLIC/g" |
    sed -e "s/PRIVATE_ADDRESS/$PRIVATE/g" |
    sed -e "s/SEED_HOST/$SEEDS/g" > conf/cassandra.yaml
  bin/cassandra $*
)

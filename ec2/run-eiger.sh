#!/bin/bash

source $(dirname $0)/ec2-utils.sh

# setup-topology must have been run before running this!
TMP=$(cat ec2-info.*)
[[ -n $TMP ]] || abort "Setup topology has not been run."

# the first server in our list is the seed.
SEED=$(cat ec2-info.* | grep $SERVER_TAG | head -n1 | awk '{print $4}')
SEEDS="        - seeds: $SEED\\n"

PUBLIC=$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)
PRIVATE=$(wget -qO- http://instance-data/latest/meta-data/local-ipv4)
TOKEN=

# we need to set our initial_token, because cassandra is borked.
# find the datacenter we belong to
for dc in $(seq 10); do 
  if (cat conf/cassandra-topology.properties | grep "DC$dc" | grep $PUBLIC); then
    # what offset are we at in our datacenter?
    offset=$(cat conf/cassandra-topology.properties | grep "DC$dc" | egrep -v '^10.' | grep -n $PUBLIC | awk -F: '{print $1}')
    offset=$((offset - 1))

    # how many nodes in our datacenter?
    dc_nodes=$(cat conf/cassandra-topology.properties | grep "DC$dc" | egrep -v '^10.' | wc -l)

    # our token is $dc + 2**127 * offset / dc_nodes
    bc_cmd="$offset*(2^127)/$dc_nodes + $dc"
    TOKEN=$(echo $bc_cmd | bc)
    echo "My dc: $dc, offset: $offset, token $TOKEN"
  fi
done

[[ -n $TOKEN ]] || abort "Failed to find self in properties file"

echo "Blowing away database...."
rm -rf /tmp/cassandra

echo Public ip: $PUBLIC, private ip: $PRIVATE, seed: $SEED
echo Seed line: $SEEDS

DIRNAME=$(readlink -f .)

rsync -e 'ssh -oStrictHostKeyChecking=no' -aip nfs.rjpower.org:$DIRNAME /tmp/
(
  cd /tmp/eiger
  cat conf/cassandra.yaml.TEMPLATE |
    sed -e "s/PUBLIC_ADDRESS/$PUBLIC/g" |
    sed -e "s/PRIVATE_ADDRESS/$PRIVATE/g" |
    sed -e "s/INITIAL_TOKEN/$TOKEN/g" |
    sed -e "s/SEED_HOST/$SEEDS/g" > conf/cassandra.yaml
  bin/cassandra $*
)

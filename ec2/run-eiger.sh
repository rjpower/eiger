#!/bin/bash

#SEEDS=$(cat ec2-public-ips.us-* | awk '{printf("        - seeds: " $1 "\\n")}')
SEEDS=$(cat ec2-public-ips.us-* | tail -n1 | awk '{printf("        - seeds: " $1 "\\n")}')


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

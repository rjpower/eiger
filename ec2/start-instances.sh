#!/bin/bash

source $(dirname $0)/ec2-utils.sh

num_servers=$1
name=$2
region=$3
[[ -n $num_servers ]] || abort "Need to specify number of servers"
[[ -n $name ]] || abort "Need to specify name for servers"
[[ -n $region ]] || abort "Need to specify region"

ami=$(ami_for_region $region)

[[ -n $ami ]] || abort "No ami found for region '$region'"

if [[ -n $INSTANCE_TYPE ]]; then
  instance_type=$INSTANCE_TYPE
else
  instance_type="m1.small"
fi

echo Starting $num_servers servers in $region
  
maybe_run "ec2-run-instances $ami -n $num_servers -t $instance_type --region=$region -f /home/power/www/aws/boot-slave.sh"

echo "Naming newly started servers."
$(dirname $0)/name-instances.sh $name $region
#!/bin/bash

source $(dirname $0)/ec2-utils.sh

num_servers=$1
name=$2
[[ -n $num_servers ]] || abort "Need to specify number of servers"
[[ -n $name ]] || abort "Need to specify name for servers"

echo Starting $num_servers servers in $REGIONS
for region in $REGIONS; do
  ami=$(ami_for_region $region)
  cmd="ec2-run-instances $ami -n $num_servers -t m1.small --region=$region -f /home/power/www/aws/boot-slave.sh"
  echo Running $cmd
  [[ -n "$PRINT_ONLY" ]] || ($cmd) &
done

wait

echo "Naming newly started servers."
$(dirname $0)/name-instances.sh $name

#!/bin/bash

source $(dirname $0)/ec2-utils.sh

name=$1
region=$2
[[ -n $name ]] || abort "Need to specify name for servers"
[[ -n $region ]] || abort "Need to specify region"

list_all $region | grep $name | awk '{print $1}' | xargs ec2-terminate-instances --region=$region

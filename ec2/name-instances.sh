#!/bin/bash

source $(dirname $0)/ec2-utils.sh

name=$1
region=$2
[[ -n $name ]] || abort "Need to specify name"
[[ -n $region ]] || abort "Need to specify region"

untagged=$(get_untagged $region | xargs -n1)
if [[ -n $untagged ]]; then
  maybe_run "ec2-create-tags --region=$region --tag Name=$name $untagged"
fi

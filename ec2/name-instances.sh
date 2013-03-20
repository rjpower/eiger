#!/bin/bash

source $(dirname $0)/ec2-utils.sh

name=$1
[[ -n $name ]] || abort "Need to specify name"

for r in $REGIONS; do
  (
    untagged=$(get_untagged $r | xargs -n1)
    echo "Tagging ($untagged) in region $r"
    if [[ -n $untagged ]]; then
      ec2-create-tags --region=$r --tag Name=$name $untagged
    fi
  )&
done

wait

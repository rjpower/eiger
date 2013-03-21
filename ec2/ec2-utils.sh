#!/bin/bash

REGIONS="us-east-1 us-west-1 ap-southeast-1 eu-west-1"
SERVER_TAG="eiger-server"

function abort() {
  echo "ABORT: $1 $2 $3 $4 $5" 1>@2
  exit 1
} 

function maybe_run() {
  if [[ -n $PRINT_ONLY ]]; then
    echo "PRINT_ONLY: $*"
  else
    echo "Running: $*"
    $*
  fi
}
function get_region() {
 wget -qO- http://instance-data/latest/dynamic/instance-identity/document | 
  grep availabilityZone | 
  awk -F'"' '{print $4}' | 
  awk -F- '{print $1 "-" $2}'
}

function get_name() {
  region=$(get_region)
  ec2-describe-tags \
    --region=$region \
    --filter "resource-type=instance" \
    --filter "resource-id=$($(dirname $0)/ec2-metadata -i | cut -d ' ' -f2)" \
    --filter "key=Name" | cut -f5
}

# return a list instance ids which do not have names. 
function get_untagged() {
  list_all $1 | grep untagged | awk '{ print $1 } ' | xargs
}

function list_all() {
  region=$1
  [[ -n $region ]] || abort "Region not specified"
  ec2-describe-instances --region=$region | 
    awk -F'[\t'] '
  /INSTANCE.*running/ { instances[$2] = 1; public[$2] = $17; private[$2] = $18 }
  /INSTANCE.*pending/ { instances[$2] = 1; public[$2] = $17; private[$2] = $18 } 
  /TAG.*Name/ { tags[$3] = $5 } 
  END { 
    for (k in instances) {
      if (k in tags) { print k, tags[k], private[k], public[k] }
      else { print k, "untagged" }
    } 
  }' | tee ec2-info.$region
}

function ami_for_region() {
  region=$1
  [[ -n $region ]] || abort "Region not specified"
  case "$region" in 
    'us-east-1' ) echo 'ami-b8d147d1' ;;
    'us-west-1' ) echo 'ami-42b39007' ;;
    'eu-west-1' ) echo 'ami-5a60692e' ;;
    'ap-southeast-1' ) echo 'ami-76206d24' ;;
  esac
}

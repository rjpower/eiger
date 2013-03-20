#!/bin/bash

REGIONS="us-east-1 us-west-1 ap-southeast-1 eu-west-1"

function get_private_ips() {
  region=$1
  [[ -n $region ]] || abort "Region not specified"
  ( ec2-describe-instances --region $region | grep INSTANCE | grep running | awk -F'[\t]' '{print $18}') | tee ec2-private-ips.$region
}

function get_public_ips() {
  region=$1
  [[ -n $region ]] || abort "Region not specified"
  ( ec2-describe-instances --region $region | grep INSTANCE | grep running | awk -F'[\t]' '{print $17}') | tee ec2-public-ips.$region
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

function get_untagged() {
  region=$1
  [[ -n $region ]] || abort "Region not specified"
  ec2-describe-instances --region=$region | 
    awk '/INSTANCE.*running/ { instances[$2] = 1 } /TAG.*Name/ { delete instances[$3] } END { for (k in instances) { print k } } '
}

function ami_for_region() {
  region=$1
  [[ -n $region ]] || abort "Region not specified"
  case "$region" in 
    'us-east-1' ) 
      echo 'ami-b8d147d1' 
      ;;
    'us-west-1' ) 
      echo 'ami-42b39007' 
      ;;
    'eu-west-1' ) 
      echo 'ami-5a60692e' 
      ;;
    'ap-southeast-1' ) 
      echo 'ami-76206d24'
      ;;
  esac
}

function abort() {
  echo "ABORT: $1 $2 $3 $4 $5"
  exit 1
} 

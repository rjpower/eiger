#!/bin/bash

REGIONS="us-east-1 us-west-1"

function get_private_ips() {
  region=$1
  ( ec2-describe-instances --region $region | grep INSTANCE | grep running | awk -F'[\t]' '{print $18}') | tee ec2-private-ips.$region
}

function get_public_ips() {
  region=$1
  ( ec2-describe-instances --region $region | grep INSTANCE | grep running | awk -F'[\t]' '{print $17}') | tee ec2-public-ips.$region
}

function get_region() {
 wget -qO- http://instance-data/latest/dynamic/instance-identity/document | 
  grep availabilityZone | 
  awk -F'"' '{print $4}' | 
  awk -F- '{print $1 "-" $2}'
}

function get_name() {
  ec2-describe-tags \
    --filter "resource-type=instance" \
    --filter "resource-id=$($(dirname $0)/ec2-metadata -i | cut -d ' ' -f2)" \
    --filter "key=Name" | cut -f5
}

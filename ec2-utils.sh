#!/bin/bash

REGIONS="us-east-1 us-west-1"

function get_private_ips() {
  (
    for region in $REGIONS; do 
       ec2-describe-instances --region $region | grep INSTANCE | grep running | awk '{print $15}'
     done
  ) | tee ec2-private-ips
}

function get_public_ips() {
  (
    for region in $REGIONS; do 
       ec2-describe-instances --region $region | grep INSTANCE | grep running | awk '{print $14}'
     done
  ) | tee ec2-public-ips
}


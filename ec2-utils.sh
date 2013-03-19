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


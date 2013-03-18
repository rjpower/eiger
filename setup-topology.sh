#!/bin/bash

cp conf/cassandra-topology.TEMPLATE  conf/cassandra-topology.properties
ec2-describe-instances | grep INSTANCE | awk '{print $15"=DC1:RAC1"}' >> conf/cassandra-topology.properties



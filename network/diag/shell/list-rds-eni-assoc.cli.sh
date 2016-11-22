#!/bin/bash 

# Copyright 2016 Amazon.com, Inc. or its affiliates.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions
# and limitations under the License.
#
# list-rds-eni-assoc.cli     Ref  rds-support-tools/network/network.README

# exit if required first parameter (VPCID) is not present 
if [[ ${1:-0} = 0 ]] ;  then
   clear
   echo 
   echo 
   echo "Usage:  list-rds-eni-assoc.cli <vpc identifier>"
   echo 
   echo 
   exit
fi

vpc_id=$1

rds_instances=`aws rds describe-db-instances --query "DBInstances[? DBSubnetGroup.VpcId=='$vpc_id'].Endpoint.Address" --output text`

for rds_instance in $rds_instances; do
        ip_address=`nslookup $rds_instance | tail -2 | head -1 | cut -d ' ' -f2`
        printf "%s\n" $rds_instance
        eni=`aws ec2 describe-network-interfaces --filters Name="vpc-id",Values="$vpc_id" Name="private-ip-address",Values="$ip_address" --query "NetworkInterfaces[].[NetworkInterfaceId]" --output text`
        if [ -z "$eni" ]; then
                eni=`aws ec2 describe-network-interfaces --filters Name="vpc-id",Values="$vpc_id" Name="association.public-ip",Values="$ip_address" --query "NetworkInterfaces[].[NetworkInterfaceId]" --output text`
                printf "%s\n"  "$eni"
                printf "\n"
                else
                printf "%s\n"  "$eni"
                printf "\n"
                fi
done
#!/bin/bash

if [ $# != 5 ]; then
	echo "Wrong Script usage. Please use as follows: create-env.sh ami_id key_name security_group_id launch_configuration count"
else
	echo "Creating Load Balancer. Website accessible from:"
	aws elb create-load-balancer --load-balancer-name nxtGenBalancer --listeners Protocol=http,LoadBalancerPort=80,InstanceProtocol=http,InstancePort=80 --availability-zones "us-west-2b"
	echo "Creating Load Blanacer Policy"
	aws elb create-load-balancer-policy --load-balancer-name nxtGenBalancer --policy-name nxtGenBalancerPolicy --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true
	echo "Configuring the Launch Policy"
	aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --security-groups $3 --instance-type t2.micro --user-data file://installenv.sh --placement AvailabilityZone=us-west-2b --placement-tenancy default
	echo "Configuring the Autoscale Group"
	aws autoscaling create-auto-scaling-group --launch-configuration-name $4 --auto-scaling-group-name nxtGenAutoScaleGroup --min-size 3 --max-size 5 --desired-capacity 4 --availability-zones "us-west-2b"
	echo "Attaching the Load Balancer to Autoscale Group"
	aws autoscaling attach-load-balancers --auto-scaling-group-name nxtGenAutoScaleGroup --load-balancer-names nxtGenBalancer
	echo "Webserver is ready for use"

fi


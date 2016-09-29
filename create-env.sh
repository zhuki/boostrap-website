#!/bin/bash

if [ $# != 7 ]; then
	echo "Wrong Script usage. Please use as follows: create-env.sh ami_id key_name security_group_id instance_type min_instances max_instances desired_instances"
else
	echo "Creating Load Balancer. Website accessible from:"
	aws elb create-load-balancer --load-balancer-name nxtGenBalancer --listeners Protocol=http,LoadBalancerPort=80,InstanceProtocol=http,InstancePort=80 --availability-zones "us-west-2b"
	echo "Creating Load Blanacer Policy"
	aws elb create-load-balancer-policy --load-balancer-name nxtGenBalancer --policy-name nxtGenBalancerPolicy --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=trueaws elb create-load-balancer-policy --load-balancer-name nxtGenBalancer --policy-name nxtGenBalancerPolicy --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true
	echo "Configuring the Launch Policy"
	aws autoscaling create-launch-configuration --launch-configuration-name nxtGen_webserver --image-id $1 --key-name $2 --security-groups $3 --instance-type $4 --user-data file://installenv.sh --placement AvailabilityZone=us-west-2b --placement-tenancy default
	echo "Configuring the Autoscale Group"
	aws autoscaling create-auto-scaling-group --launch-configuration-name nxtGen_webserver --auto-scaling-group-name nxtGenAutoScaleGroup --min-size $5 --max-size $6 --desired-capacity $7 --availability-zones "us-west-2b"
	echo "Attaching the Load Balancer to Autoscale Group"
	aws autoscaling attach-load-balancers --auto-scaling-group-name nxtGenAutoScaleGroup --load-balancer-names nxtGenBalancer
	echo "Webserver is ready for use"

fi


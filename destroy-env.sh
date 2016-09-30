#!/bin/bash

if [ $# != 1 ]; then
	echo "Wrong Script usage. Please use as follows: destroy-env.sh autoscaling_group"
else
	LoadBalancerName=`aws autoscaling describe-load-balancers --auto-scaling-group-name $1 --output text --query LoadBalancers[*].LoadBalancerName`
	echo "Detaching Load Balancer"
	aws autoscaling detach-load-balancers --auto-scaling-group-name $1 --load-balancer-names $LoadBalancerName
	LaunchConfiguration=`aws autoscaling describe-auto-scaling-groups --output text --query AutoScalingGroups[*].Instances[0].LaunchConfigurationName`
	RunningInstances=`aws autoscaling describe-auto-scaling-instances --output text --query AutoScalingInstances[*].InstanceId`
	echo "Emptying the Autoscale Group"
	aws autoscaling update-auto-scaling-group --auto-scaling-group-name $1 --min-size 0 --max-size 0 --desired-capacity 0
	echo "Waiting for Instances to be terminated... This may take a while."
	aws ec2 wait instance-terminated --instance-ids $RunningInstances
	echo "Deleting the Autoscale Group"
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $1
	echo "Deleting Launch Configuration"
	aws autoscaling delete-launch-configuration --launch-configuration-name $LaunchConfiguration
	echo "Deleting Load Balancer"
	aws elb delete-load-balancer --load-balancer-name $LoadBalancerName
	echo "Deployment has been destroyed and instances have been terminated"

fi


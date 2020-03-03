#!/usr/bin/env bash

#Using script from http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html
# Install awslogs
yum update -y
yum install -y awslogs jq

# ECS config
${ecs_config}
{
  echo ECS_CLUSTER=${cluster_name}
  echo ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_logging}
} >> /etc/ecs/ecs.config

# Inject the CloudWatch Logs configuration file contents
cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state        
 
[/var/log/messages]
file = /var/log/messages
log_group_name = /${cluster_name}/var/log/messages
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %b %d %H:%M:%S
[/var/log/docker]
file = /var/log/docker
log_group_name = /${cluster_name}/var/log/docker
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f
[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = /${cluster_name}/var/log/ecs/ecs-init
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = /${cluster_name}/var/log/ecs/ecs-agent
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
EOF

# Set the region to send CloudWatch Logs data (the region where the container instance is located)
REGION=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
sed -i -e "s/region = us-east-1/region = $REGION/g" /etc/awslogs/awscli.conf

# Set the ip address of the node 
CONTAINER_INSTANCE_ID=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
sed -i -e "s/{container_instance_id}/$CONTAINER_INSTANCE_ID/g" /etc/awslogs/awslogs.conf

cat > /etc/init/awslogjob.conf <<- EOF
#upstart-job
description "Configure and start CloudWatch Logs agent on Amazon ECS container instance"
author "Amazon Web Services"
start on started ecs
script
	exec 2>>/var/log/ecs/cloudwatch-logs-start.log
	set -x
	
	until curl -s http://localhost:51678/v1/metadata
	do
		sleep 1	
	done
	
	service awslogs start
	chkconfig awslogs on
end script
EOF

start ecs

echo "Done"
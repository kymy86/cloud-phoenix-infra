#!/usr/bin/env bash

set -euxo pipefile

mkdir -p /home/ec2-user/mongodb
cd /home/ec2-user/mongodb

aws cp s3://${bucket_name}/orchestrator.sh orchestrator.sh
chmod +x orchestrator.sh

aws cp s3://${bucket_name}/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
chmod +x /etc/init.d/disable-transparent-hugepages
chkconfig --add disable-transparent-hugepages

aws cp s3://${bucket_name}/init-replica.sh init.sh
aws cp s3://${bucket_name}/signal-final-status.sh signal-final-status.sh
chmod +x init.sh
chmod +x signal-final-status.sh

echo "export TABLE_NAMETAG=${app_name}" >> config.sh
echo "export MongoDBVersion=${mongodb_version}" >> config.sh
echo "export VPC=${vpc}" >> config.sh
echo "export MONGODB_ADMIN_USER=${mongodb_admin_user}" >> config.sh


mkdir -p /mongo_auth
./init.sh > install.log 2>&1
#  Cleanup
#rm -rf *
chown -R ec2-user:ec2-user /home/ec2-user/

/home/ec2-user/mongodb/signal-final-status.sh 0

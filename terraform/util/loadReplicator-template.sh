#!/bin/bash

max_attempts=10
wait_time=6

user=$(grep "^[^#;]"  ../../util/connect.password | head -n 1)
STATUS="NOK"
count=0

while [ "$STATUS" = "NOK" ]; do
	curl -u $user -s http://${external_ip} | jq -r '.kafka_cluster_id' | grep "lkc-" &> /dev/null
	if [ $? == 0 ]; then
   		echo "Kafka Connect Up and Running"
		STATUS="OK"
	else
		count=`expr $count + 1`
		if [ $count -ge $max_attempts ]; then
                	echo "Too many attempts. Giving up ..."
                	exit 1
        	fi
		echo "Service Not Ready yet ..."
		echo "Waiting $${wait_time} seconds ..."
		sleep $wait_time
	fi
done

check=$(curl -u $${user} -s http://${external_ip}/connectors | jq '. | contains(["ccloud-replicator"])')
echo $check
if [ "$check" = "true" ];then
	echo "Connector Loaded "
else
	echo "Connector Not Loaded"
	curl -u $user -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://${external_ip}/connectors/ -d @kafka-replicator-config.json
fi


#!/bin/bash

# There is a lot of shellcheck disables because it is not a true bash script, but rather a template
# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

# shellcheck disable=SC2154
ASG_NAME="${asgname}"
# shellcheck disable=SC2154
REGION="${region}"
# shellcheck disable=SC2154
EXPECTED_SIZE="${size}"

# Return the id of each instance in the cluster.
function cluster-instance-ids {
    aws --region="$REGION" autoscaling describe-auto-scaling-groups --auto-scaling-group-name "$ASG_NAME" \
        --query="AutoScalingGroups[].Instances[].InstanceId" --output="text" | xargs -n1 echo
}

# Return the private DNS name of each instance in the cluster.
function cluster-dns-names {
    for id in $(cluster-instance-ids)
    do
        aws --region="$REGION" ec2 describe-instances \
            --query="Reservations[].Instances[].[PrivateDnsName]" \
            --output="text" \
            --instance-ids="$id"
    done
}

# Wait until we have as many cluster instances as we are expecting.
while COUNT=$(cluster-instance-ids | wc -l) && [ "$COUNT" -lt "$EXPECTED_SIZE" ]
do
    echo "$COUNT instances in the cluster, waiting for $EXPECTED_SIZE instances to warm up..."
    sleep 1
done

# Get instance private IP address.
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
# Get instance DNS name, all DNS names in the cluster and neighbor DNS names.
DNS_NAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
# shellcheck disable=SC2034
mapfile -t ALL_DNS_NAMES < <(cluster-dns-names)
# shellcheck disable=SC2034 disable=1083
NEIGHBOR_DNS_NAMES=( $${ALL_DNS_NAMES[@]/$${DNS_NAME}/} )
echo "Instance DNS name is: $DNS_NAME, Cluster DNS names are: $${ALL_DNS_NAMES[@]}, neighbor DNS names are: $${NEIGHBOR_DNS_NAMES[@]}"

JOIN_LINE=""
# shellcheck disable=SC2066
for name in "$${NEIGHBOR_DNS_NAMES[@]}"
do
    JOIN_LINE=$JOIN_LINE"-retry-join=$name "
done

# Start the Consul server.
# shellcheck disable=SC2086
docker run \
    --detach \
    --net=host \
    --name=consul \
    consul:1.4.4 \
    agent \
    -server \
    -ui \
    -bind="$IP" \
    -client="0.0.0.0" \
    $JOIN_LINE \
    -bootstrap-expect="$EXPECTED_SIZE"

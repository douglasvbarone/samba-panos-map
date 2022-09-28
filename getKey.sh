#!/bin/bash
# This script is used to get the API key from a palo alto firewall

FW_MGMT_IP=$1
USERNAME=$2
PASSWD=$3

# Check parameters
if [ $# -ne 3 ]; then
  echo "Usage: $0 <firewall_ip> <username> <password>"
  exit 1
fi

URL="https://$FW_MGMT_IP/api/?type=keygen&user=$USERNAME&password=$PASSWD"

# Get the key from firewall
curl -k -s -X POST "$URL" | grep -oP '(?<=<key>)[^<]+'

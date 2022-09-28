#!/bin/bash

# This script is used to map samba users to a palo alto firewall using the XML API
# Check parameters
if [ $# -ne 2 ]; then
  echo "Usage: $0 <firewall_ip> <key>"
  exit 1
fi

# Configuration
FW_MGMT_IP=$1
FW_KEY=$2
TIMEOUT_IN_MINUTES=5

CURL=$(which curl)

# Get current logged in users
LOGGED_USERS=$(sudo smbstatus -b | tail -n +5)

# Count logged in users
LOGGED_USERS_COUNT=$(echo "$LOGGED_USERS" | wc -l)

while read -r line; do
  USER=$(echo $line | awk '{print $2}')
  IP=$(echo $line | awk '{print $5}')

  # Vefiry if user is a computer account (ends with $)
  if [[ $USER =~ \$ ]]; then
    echo "User $USER is a computer account, skipping"
    continue
  fi

  # Verify if user is 'nobody'
  if [[ $USER = nobody ]]; then
    echo "Nobody account, skipping"
    continue
  fi

  echo "Mapping $USER to $IP"
  ENTRIES="$ENTRIES<entry%20name=\"$USER\"%20ip=\"$IP\"%20timeout=\"$TIMEOUT_IN_MINUTES\"></entry>"
done <<<"$LOGGED_USERS"

# Check if ENTRIES is empty
if [ -z "$ENTRIES" ]; then
  echo "No users logged in, skipping"
  exit 0
fi

COMMAND="<uid-message><version>1.0</version><type>update</type><payload><login>$ENTRIES</login></payload></uid-message>"

URL="https://$FW_MGMT_IP/api/?type=user-id&key=$FW_KEY&cmd=$COMMAND"

echo ---

$CURL -k -H "Content-Type: application/xml" -X POST "$URL"

# Get current datetime
NOW=$(date +"%Y-%m-%d %H:%M:%S")

echo $NOW " - $LOGGED_USERS_COUNT users mapped to firewall" >/var/log/smb-pan.log

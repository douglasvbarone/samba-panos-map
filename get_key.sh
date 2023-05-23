#!/bin/bash
# Configuration
FW_MGMT_IP=$1
USER=$2
PASSWD=$3

[ $# -eq 0 ] && {
  echo "ERRO - Uso: $0 Exemplo: 192.168.1.1 admin password"
  exit 1
}

wget --output-document=/tmp/getkey.txt "https://$FW_MGMT_IP/api/?type=keygen&user=$USER&password=$PASSWD" --no-check-certificate

KEY=$(cat /tmp/getkey.txt | awk '{print $4}' | grep -o '<key>.*</key>' | sed 's/\(<key>\|<\/key>\)//g')

echo "Valor da variavel KEY do PaloAlto >>> $KEY"

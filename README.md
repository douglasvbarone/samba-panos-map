# Samba to PAN OS user mapping

This script maps Samba logged in users to a Palo Alto Firewall using the XML API.

Tested with Samba version 4.13.17-Ubuntu and PAN OS versions 8.1.0 and 10.2.3-h2.

## Instructions

- Clone or download this repo into `/root/` (or another folder of your choice, but take note of it).
- Create a user with admin privileges on the target firewall (it's recommended, but not mandatory, that this user have only access to the XML API thru a custom role based profile)
- Run the `getKey.sh` script passing the management IP address as first parameter, username as second parameter and password as third parameter. The script will print out the API key needed to run the mapping script. You only have to do this once. Ex.:

```
$ ./getKey.sh 192.168.0.2 username password
LUFRPT1B...ASDFerjbyr0=
```

- Then, call `smb-pan.sh` as root (or sudo) passing the management IP address and the API key from the previous script, like so:

```
# ./smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=
```

This will map current logged users to the firewall. You can verify it in the firewall monitor.

## Scheduling Cron jobs

Now, you need to schedule the execution of the script. I recommended 10 seconds interval. The easy way of doing it is putting 6 entries on `/etc/crontab` (not so pretty... But...):

```
# /etc/crontab
* * * * *  root    bash /home/root/samba-panos-map/smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=
* * * * *  root    ( sleep 10; bash /home/root/samba-panos-map/smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=)
* * * * *  root    ( sleep 20; bash /home/root/samba-panos-map/smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=)
* * * * *  root    ( sleep 30; bash /home/root/samba-panos-map/smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=)
* * * * *  root    ( sleep 40; bash /home/root/samba-panos-map/smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=)
* * * * *  root    ( sleep 50; bash /home/root/samba-panos-map/smb-pan.sh 192.168.0.2 LUFRPT1B...ASDFerjbyr0=)
```

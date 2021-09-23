#!/bin/bash

# This script checks the difference in IP addresses returned by your website and the IP
# address that is stored by duckdns.org to redirect your site to your current dynamically
# assigned IP address.  Provided you are online, it updates your duckdns.org entry.
# The benefit to you is that it gives a clear indicator of the success or otherwise of
# your updates and it caneasily be automated with crontab. The benefit to duckdns is that
# instead of sending an IP address update curl to them every X minutes, making for lots
# of unnecessary traffic, you only send an update curl when your IP address and duckdns
# entry no longer match, which often happens when your router reboots or periodically
# by your ISP when you have dynamic IP addresses allocated.

DATET=$(date +'%Y%m%dT%H%M')
# Path where you want logs written
LOGDIR="~/duckdns"
# Your site - dot - top level domain, i.e., where you would browse to to see your website 
SITETLD="mywebsite.com"
# The URI shown when you navigate to https://www.duckdns.org/install.jsp?tab=linux-cron&domain={your duckdns domain token}
# Replace MYWEBSITE and TOKEN with yours!
URIDOMTOKEN="https://www.duckdns.org/update?domains=MYWEBSITE&token=TOKEN&ip="

# Curl to get the current dynamic public IP address for the connection
IPPUB=`curl -s ifconfig.me`
echo $IPPUB

# Ping the SITETLD address once, grep the results, $3 is the IP address in parentheses, strip the parentheses with tr -d
IPDNS=`ping -c 1 $SITETLD | grep "PING $SITETLD" | awk '{print $3}' | tr -d '()'`
echo $IPDNS

# Start checking that 1, whether the addresses are the same, and if they are, that they are valid IP addresses
if [ "$IPPUB" == "$IPDNS" ] && [[ $IPPUB =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
 # The current public IP address and DNS are the same (and valid IP addresses) so no update is required. 
 # Just write to the log file that it was all good. 
 echo "$DATET $IPPUB addresses match (no update needed: ref#1)" >> $LOGDIR/$IPPUB.log
 # Uncomment the exit 0 command if you also want to test resetting the DuckDNS entry rather than stopping
 exit 0
fi

# If the IP addresses are both valid then
# EITHER
#  IPPUB needs to be used to update Duckdns
# OR
#  We are offline / the Ping/Curl failed.
if [[ $IPDNS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && [[ $IPPUB =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
 # The IP addresses are valid, so we are online and so we need to update the IP address(es) at DuckDNS
 echo "$DATET new IP address $IPDNS (update needed: ref#2)" >> $LOGDIR/$IPPUB.log
 # Do the update at duckdns (Reference: https://www.duckdns.org/install.jsp)
 echo url=$URIDOMTOKEN | /usr/bin/curl -k -o $LOGDIR/duckdns.$SITETLD.$DATET.log -K -  
 sleep 30
 echo $SITETLD >> $LOGDIR/$IPPUB.log
 # Should be OK (success) or KO (fail)
 cat $LOGDIR/duckdns.$SITETLD.$DATET.log >> $LOGDIR/$IPPUB.log
 echo "---------------------------------" >> $LOGDIR/$IPPUB.log
elif [[ $IPPUB =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
 # Curl failed
 echo "$DATET FAIL: could not get valid IP address from curl -s ifconfig.me ($IPPUB) (No action: ref#3)" >> $LOGDIR/duck.FAILS.log
elif [[ $IPDNS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
 # Ping failed
 echo "$DATET FAIL: could not get valid IP address from ping -c 1 $SITETLD ($IPDNS) (No action: ref#4)" >> $LOGDIR/duck.FAILS.log
else
 # We are offline (probably) so just note that to the log
 echo "$DATET FAIL: could not get valid IP addresses from curl -s ifconfig.me ($IPPUB) and ping -c 1 $SITETLD ($IPDNS) (No action: ref#5)" >> $LOGDIR/duck.FAILS.log
fi

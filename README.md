# duckdns-check-update
Bash script to check the difference between incumbent IP address and duckdns.org domain IP address

## links
- [Repo](https://github.com/kennypete/duckdns-check-update)

## about and installation
"[Duck DNS](https://www.duckdns.org/about.jsp) is a free service which will point a DNS (sub domains of duckdns.org) to an IP of your choice". It enables you to give your server/router an easily "rememberable name", where the server's IP address will/is likely to change when your server/router restarts or reconnects and its IP address is set by the provider of that connection, meaning may it update at any time.

An obvious use case for Duck DNS is a self-hosted website. You may have purchased a cheap domain and want to use Apache or Nginx to serve a website. That's fine, but unless you have a static IP address, you need to have the CNAME record point to a DNS services to redirect any http/https traffic to the right IP address. That's where Duck DNS comes in - it is a free service that enables you to point to it and it holds your current IP address. 

The missing bit is how to continually update Duck DNS with your IP address. The Duck DNS [install page](https://www.duckdns.org/install.jsp) outlines how to do this for lots of operating systems. However, what it suggests (using linux cron as the example) is doing a regular curl to repeatedly send update URIs to Duck DNS. For example:

    echo url="https://www.duckdns.org/update?domains=exampledomain&token=a7c4d0ad-114e-40ef-ba1d-d217904a50f2&ip=" | curl -k -o ~/duckdns/duck.log -K -

...and then having a crontab run regularly, for example:

    */5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1

What this means, however, is that over time you will send a lot of requests to this free service, and traffic costs them. What this script does is keeps a lid on that and provides you with log files. It does it by comparing your IP address to Duck DNS's record and, *only if they differ*, sends the curl to update Duck DNS.

The script, duck.sh, is the same as recommended in the Duck DNS *linux cron* "how to" [install page](https://www.duckdns.org/install.jsp), meaning that its instructions are compatible with this script other than subbing it for the one-line duck.sh that they suggest.

Save duck.sh to ~/duckdns (or otherwise you will need to ensure that you adjust your setup accordingly, incuding the LOGDIR, noted below).

The customisation modifications you **MUST** make to duck.sh are to change:
- SITETLD variable to whatever your {domain.tld} is. That is, change "mywebsite.com" to whatever yours is
- URIDOMTOKEN variable, but changing MYWEBSITE to your domain and TOKEN to your token (shown on your Duck DNS home page)

The customisation modifications you MAY make to duck.sh are to change:
- LOGDIR variable to write to a different path. (The default is to write to the same directory as duck.sh)

## built with
- Bash

## author
Peter Kenny

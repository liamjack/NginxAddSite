#!/bin/bash

# Default location to store site directories
defaultSiteDirectory="/home/username/"

# Path to nginx site config directory
nginxSitesDirectory="/etc/nginx/sites/"

# Path to acmetool's live certificates
acmeLiveDirectory="/var/run/acme/live/"

# The IPv4 address of your server
serverIp="123.123.123.123"

# The domain name of the server (keep the trailing dot)
serverName="server1.example.com."

function fatalError() {
    echo "[ERROR] $1"
    exit 1
}

declare -A domainNames

i=1

# Get domain name(s)

while true; do
    read -p "Domain name: " domainName

    if test -z $domainName; then
        fatalError "Domain name is empty."      
    fi

    if test "${#domainName}" -lt 3; then
        fatalError "Domain name is too short."
    fi

    if test "${#domainName}" -gt 255; then
        fatalError "Domain name is too long."
    fi

    ip=`dig +short $domainName`
    nbIp=`echo $ip | wc -w`

    if test "$nbIp" = "0"; then
        fatalError "$domainName does not resolve."
    fi

    if test $nbIp -gt 1; then
        # There are multiple IPs, grab the first one in the list
        ip=`echo $ip | cut -d " " -f 1`
    fi

    if test "$ip" != "$serverIp" -a "$ip" != "$serverName"; then
        fatalError "$domainName is not pointing to $serverIp"
    fi

    domainNames[$i]=$domainName

    read -p "Do you want to add another domain name ? [y/N]: " key

    if test $key = "n" -a $key != "y" -a $key != "Y"; then
        break
    fi

    i=$(($i + 1))
done

# Check at least one domain name was provided

if test ${#domainNames[@]} -eq 0; then
    fatalError "At least one domain name is required."
fi

mainDomainName=${domainNames[1]}

read -p "Site directory [Default: $defaultSiteDirectory$mainDomainName]:" siteDirectory

if test -z $siteDirectory; then
    siteDirectory="$defaultSiteDirectory$mainDomainName"
fi

if test -e $siteDirectory; then
    # Directory exists

    if test ! -d $siteDirectory; then
        fatalError "Site directory is not a directory"
    fi

    echo "[INFO] Site directory already exists."
else
    # Directory does not exist
    echo "[INFO] Site directory does not exist."

    # Create site directory
    mkdir -m 755 -p $siteDirectory 

    if test $? -ne 0; then
        fatalError "Failed to create site directory"
    fi

    echo "[INFO] Site directory created successfully."
fi

tempConfig=`mktemp`

# Create / overwrite Nginx configuration file

cp "siteTemplate.txt" "$tempConfig"

# Replace placeholders

sed -i "s~%DOMAINNAMES%~${domainNames[*]}~g" "$tempConfig"
sed -i "s~%SITEDIRECTORY%~$siteDirectory~g" "$tempConfig"
sed -i "s~%MAINDOMAINNAME%~$mainDomainName~g" "$tempConfig"

# Move to Nginx sites directory

sudo mv "$tempConfig" "$nginxSitesDirectory/$mainDomainName"

if test $? -ne 0; then
    fatalError "Failed to move Nginx configuration file"
fi

# Reload Nginx configuration

sudo /etc/init.d/nginx reload

if test $? -ne 0; then
    fatalError "Failed to reload Nginx"
fi

# Request LE certificate

sudo acmetool want "${domainNames[*]}"

# Reload Nginx configuration one more time

sudo /etc/init.d/nginx reload

if test $? -ne 0; then
    fatalError "Failed to reload Nginx"
fi

echo "[SUCCESS] Site added successfully

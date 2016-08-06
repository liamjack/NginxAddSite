# NginxAddSite

### Description

A simple script to add new sites to Nginx, with full Let's Encrypt and HSTS integration.

### Requirements

* [acmetool](https://github.com/hlandau/acme)
* nginx
* php7-fpm
* dnsutils

# Installation

* [Install acmetool](https://github.com/hlandau/acme#getting-started)
* Run `sudo acmetool quickstart --expert` 
* Choose `1) Let's Encrypt (Live)`
* Choose either RSA or ECDSA, your choice, and the appropriate key size (4096 recommended) / curve (NIST P-384 recommended)
* Choose `1) WEBROOT`
* Enter the following webroot path: `/home/username/public_html/.well-known/acme-challenge`, replacing `username` with your username
* Modify `/home/username/addSite.txt`, changing `defaultSiteDirectory`, `serverIp` and `serverName` to appropriate values
* Copy the files and folders in `/home/username` to your home directory on the server
* Modify `/etc/nginx/global.conf`, replacing `username` with your username
* Modify `/etc/nginx/global-ssl.conf` replacing `username` with your username
* Modify `/etc/nginx/sites/default` replacing `username` with your username
* Copy the files and folders in `/etc/nginx` to `/etc/nginx` on the server
* Restart Nginx (`/etc/init.d/nginx restart`)

# Usage

In this use case we will be trying to create an Nginx site for the following domain: `example.com` along with the www extension: `www.example.com`

* Run `./addSite.sh`
* Enter the domain name `example.com` (reminder: the domain name must point to your server)
* Add another domain by typing `y`
* Enter the domain name `www.example.com`
* Stop adding domains by typing `n`
* Choose the default site directory by pressing enter
* Give it a couple of seconds
* Voilà !

Now by accessing your `example.com` and `www.example.com` you should have an SSL enabled site that you can modify by changing files in `/home/username/example.com`

# Problems, bugs, ideas...

If you encounter a problem, a bug or come up with a great idea to improve the tool feel free to open a [new issue](https://github.com/cuonic/NginxAddSite/issues/new)

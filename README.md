## Easy WP
Created to easily install WordPress on VPS running CentOS 7.x, with php 7, mysql 5.6, and Nginx. The default settings will install Lets Encrypt SSL cert to the domain (currently not working with CloudFlare, turn off CloudFlare for now), and update Nginx conf file automatically. EasyWP (ewp) will also correctly set the permissions and SELinux configuration on the domain folder. If a cache is needed ewp will install a redis cache if the option is specified during install, see below for working code. Please do not use this repo for production servers/sites.

* centos 7
* php 7
* mysql 5.6
* nginx 1.9.9
* wpcli
* LetsEncrypt SSL by default
* http2

## Items still todo

* Lets Encrypt cert renewal
* ~~Site removal, disable, and re enable~~
* Updating of ewp without running install
* ~~Add ability to create non-ssl WordPress site~~


## Install

```
git clone https://github.com/mylivingweb/EasyWP.git
cd EasyWP
./install.sh
```

## Using

```
ewp site create domain.tld
ewp site create domain.tld --redis
```




Some code borrowed from [https://github.com/bradallenfisher/php7-fpm-centos7-mysql56](https://github.com/bradallenfisher/php7-fpm-centos7-mysql56) and [rtCamp](https://github.com/rtCamp)

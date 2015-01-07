#!/bin/bash
## Add duo security repo
echo "[duosecurity]
name=Duo Security Repository
baseurl=http://pkg.duosecurity.com/RedHat/\$releasever/\$basearch
enabled=1
gpgcheck=1" > /etc/yum.repos.d/duosecurity.repo
## Add duo security key
rpm --import https://www.duosecurity.com/RPM-GPG-KEY-DUO
## Install duo security
yum -y install duo_unix pam-devel
## Add duo configuration
echo "[duo]
; Duo integration key
ikey = 
; Duo secret key
skey = 
; Duo API host
host = api-.duosecurity.com
; Send command for Duo Push authentication
; pushinfo = yes
; Proxy information
;http_proxy=http://<proxy_server>:8080
; Group Limitations (uncomment if you want to limit 2FA to a particular group)
; group = <group UMG>" > /etc/duo/login_duo.conf
## Change config file to read only by owner
chmod 600 /etc/duo/login_duo.conf
## Change owner
chown sshd:root /etc/duo/login_duo.conf
## Append SSH items to SSH config
echo "PermitTunnel no" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
## Force duo login
echo "ForceCommand /usr/sbin/login_duo" >> /etc/ssh/sshd_config
## Pam.d configs
#echo "auth    required    pam_duo.so" >> /etc/pam.d/sshd
#echo "auth    sufficient  pam_duo.so" >> /etc/pam.d/system-auth
## SELinux needs
#sudo make -C pam_duo semodule
## Restart SSH service
service sshd restart

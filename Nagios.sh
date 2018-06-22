#!/bin/bash
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bon:/root/bin
#script to install and configure nagios client in CentOs servers
#Author : Leegin Bernads T.S
#Date : 13/08/2017

#Install GCC Compiler, GD development Libraries,  Xinetd, and Make
yum -y install gcc glibc glibc-common gd gd-devel openssl-devel xinetd make

#Create a Nagios user
/usr/sbin/useradd -m nagios
pass='PASSWORD OF USER "nagios"'
passwd nagios <<EOF
$pass
$pass
EOF

#Create a new group for nagios
/usr/sbin/groupadd nagcmd
/usr/sbin/usermod -a -G nagcmd nagios

#Download NRPE client
wget http://208.69.59.132/Nagios/nrpe-2.12.tar.gz
tar -xf nrpe-2.12.tar.gz
cd nrpe-2.12

#Install the NRPE application
./configure
make all
make install-daemon
make install-plugin
make install-daemon-config
make install-xinetd

#Configure the nrpe service to xinetd.
sed -i 's/127.0.0.1/127.0.0.1 $NAGIOS_MASTER_IP/g' /etc/xinetd.d/nrpe  #Replace $NAGIOS_MASTER_IP with the IP address of your nagios master server.

#Edit /etc/services and insert to the “UNIX specific services” section
sed -i "300i nrpe	5666/tcp" /etc/services 

#Restart xinetd service
service xinetd restart

#Download the plugins
wget http://208.69.59.132/Nagios/nagios-plugins-1.4.14.tar.gz
tar -xf nagios-plugins-1.4.14.tar.gz
cd nagios-plugins-1.4.14
./configure
make
make install

#Configure the NRPE
echo ' command[check_disk]=/usr/local/nagios/libexec/check_disk -w 10% -c 5% -A -i /var/named/chroot/var/named -i /var/named/chroot/etc/named -i /var/named/chroot/etc/rndc.key -i /var/named/chroot/usr/lib64/bind' >> /usr/local/nagios/etc/nrpe.cfg

#Restart xinetd
service xinetd restart

#Check the NRPE working from the nagios server.
/usr/local/nagios/libexec/check_nrpe -H localhost

#Open the port 5666 in firewall
iptables -A INPUT -p tcp --dport 5666 -j ACCEPT
service iptables restart

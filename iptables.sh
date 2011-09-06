#!/bin/bash

IPT='/sbin/iptables'
EXTIF='eth0'
INTIF='br0'
LOIF='lo'
PRIVTUNIF='tun0'
PUBTUNIF='tun1'

ONEILL=192.168.42.3

function getIP
{
    hostx $1 | grep ^$1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
}
function getIFIP
{
    ip addr show dev "$1" | grep -Eo 'inet *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sed -e 's/.*inet *//'
}

eth0_ip=$(getIFIP ${EXTIF})

# Flush/delete chains
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X

# Policies
$IPT -P INPUT DROP
$IPT -P FORWARD DROP

# Set up NAT
$IPT -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
$IPT -t nat -A POSTROUTING -o $PUBTUNIF -j MASQUERADE
#$IPT -t nat -A POSTROUTING -o $PRIVTUNIF -j MASQUERADE
$IPT -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -i $INTIF -o $INTIF -j ACCEPT
$IPT -A FORWARD -i $INTIF -o $PUBTUNIF -j ACCEPT
$IPT -A FORWARD -i $PUBTUNIF -o $INTIF -d 192.168.42.3 -j ACCEPT
$IPT -A FORWARD -i $PUBTUNIF -o $INTIF -d 192.168.42.4 -j ACCEPT
#$IPT -A FORWARD -i $INTIF -o $PRIVTUNIF -j ACCEPT
$IPT -A FORWARD -p icmp --icmp-type fragmentation-needed -j ACCEPT

# Allows
# Established/Related
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# all loopback
$IPT -A INPUT -i $LOIF -j ACCEPT
# all intranet input
$IPT -A INPUT -i $INTIF -j ACCEPT
# external pings - rate limited
$IPT -A INPUT -i $EXTIF -p icmp --icmp-type echo-request -m limit --limit 2/second --limit-burst 2 -j ACCEPT
# external HTTP - rate limited
#$IPT -A INPUT -i $EXTIF -p tcp --dport 80 -m state --state NEW -m limit --limit 3/second --limit-burst 6 -j ACCEPT
# external SVN - rate limited
#$IPT -A INPUT -i $EXTIF -p tcp --dport 3690 -m state --state NEW -m limit --limit 2/second --limit-burst 4 -j ACCEPT
# external OpenVPN connection requests
#$IPT -A INPUT -i $EXTIF -p udp --dport 1194 -m state --state NEW -m limit --limit 2/minute --limit-burst 2 -j ACCEPT
$IPT -A INPUT -i $EXTIF -p tcp --dport 443 -m state --state NEW -m limit --limit 2/minute --limit-burst 2 -j ACCEPT
# ICMP fragmentation needed messages
$IPT -A INPUT -i $EXTIF -p icmp --icmp-type fragmentation-needed -m limit --limit 10/second --limit-burst 20 -j ACCEPT

# VPN pings
$IPT -A INPUT -i $PUBTUNIF -p icmp --icmp-type echo-request -m limit --limit 2/second --limit-burst 2 -j ACCEPT
# VPN subversion
#$IPT -A INPUT -i $PUBTUNIF -p tcp --dport 3690 -j ACCEPT
# VPN NFS
$IPT -A INPUT -i $PUBTUNIF -p udp -m multiport --dports 111,2049,4000:4003 -j ACCEPT
$IPT -A INPUT -i $PUBTUNIF -p tcp -m multiport --dports 111,2049,4000:4003 -j ACCEPT
# VPN squid proxy
$IPT -A INPUT -i $PUBTUNIF -p tcp --dport 3128 -j ACCEPT
# VPN rsync
$IPT -A INPUT -i $PUBTUNIF -p tcp --dport 873 -j ACCEPT

## VPN pings
#$IPT -A INPUT -i $PRIVTUNIF -p icmp --icmp-type echo-request -m limit --limit 2/second --limit-burst 2 -j ACCEPT
## VPN subversion
#$IPT -A INPUT -i $PRIVTUNIF -p tcp --dport 3690 -j ACCEPT
## VPN ssh
#$IPT -A INPUT -i $PRIVTUNIF -p tcp --dport 22 -j ACCEPT
## VPN NFS
#$IPT -A INPUT -i $PRIVTUNIF -p udp -m multiport --dports 111,2049,44444:44446 -j ACCEPT
#$IPT -A INPUT -i $PRIVTUNIF -p tcp -m multiport --dports 111,2049,44444:44446 -j ACCEPT
## VPN squid proxy
##$IPT -A INPUT -i $PRIVTUNIF -p tcp --dport 3128 -j ACCEPT
## VPN rsync
#$IPT -A INPUT -i $PRIVTUNIF -p tcp --dport 873 -j ACCEPT

# Samba
#$IPT -A INPUT -p udp --sport 137 -j ACCEPT
#$IPT -A INPUT -p udp --sport 139 -j ACCEPT
#$IPT -A INPUT -p udp --sport 445 -j ACCEPT

# Log dropped
#$IPT -A INPUT -j LOG --log-prefix "IPTABLES_WOULD_DROP "

# DNATs
# http
$IPT -t nat -A PREROUTING -d $eth0_ip -p tcp --dport 80 -j DNAT --to-destination $ONEILL
$IPT -A FORWARD -i $EXTIF -o $INTIF -d $ONEILL -p tcp --dport 80 -j ACCEPT
#$IPT -t nat -A POSTROUTING -s 192.168.42.0/24 -d $ONEILL -p tcp --dport 80 -j MASQUERADE

# ssh for git
$IPT -t nat -A PREROUTING -d $eth0_ip -p tcp --dport 22 -j DNAT --to-destination $ONEILL
$IPT -A FORWARD -i $EXTIF -o $INTIF -d $ONEILL -p tcp --dport 22 -j ACCEPT

# git
$IPT -t nat -A PREROUTING -d $eth0_ip -p tcp --dport 9418 -j DNAT --to-destination $ONEILL
$IPT -A FORWARD -i $EXTIF -o $INTIF -d $ONEILL -p tcp --dport 9418 -j ACCEPT

# squid
#$IPT -t nat -A PREROUTING -i $PUBTUNIF -p tcp --dport 3128 -j DNAT --to-destination $ONEILL
#$IPT -A FORWARD -i $PUBTUNIF -o $INTIF -p tcp --dport 3128 -j ACCEPT
#$IPT -t nat -A PREROUTING -i $PRIVTUNIF -p tcp --dport 3128 -j DNAT --to-destination $ONEILL
#$IPT -A FORWARD -i $PRIVTUNIF -o $INTIF -p tcp --dport 3128 -j ACCEPT

# old https vpn
#$IPT -t nat -A PREROUTING -i $EXTIF -p tcp --dport 443 -j DNAT --to-destination 192.168.42.11
#$IPT -A FORWARD -i $EXTIF -o $INTIF -d 192.168.42.11 -p tcp --dport 443 -j ACCEPT

# old udp vpn
#$IPT -t nat -A PREROUTING -i $EXTIF -p udp --dport 1194 -j DNAT --to-destination 192.168.42.11
#$IPT -A FORWARD -i $EXTIF -o $INTIF -d 192.168.42.11 -p udp --dport 1194 -j ACCEPT

# SNATs
#$IPT -t nat -A PREROUTING -i $INTIF -d $eth0_ip -p udp --dport 1194 -j DNAT --to-destination 192.168.42.1:1194
#$IPT -t nat -A POSTROUTING -o $INTIF -s 192.168.42.1 -p udp --sport 1194 -j SNAT --to-source $eth0_ip:1194

# Drop any other new connection
#$IPT -A INPUT -i $EXTIF -m state --state NEW,INVALID -j DROP
#$IPT -A FORWARD -i $EXTIF -m state --state NEW,INVALID -j DROP


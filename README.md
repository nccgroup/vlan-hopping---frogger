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

Run as root.

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
* Vconfig (built into Backtrack)


Tested on Backtrack 5 and Kali.

* Notes for VMware. VLAN hopping generally (not just this script) can have issues within VMware if running the VM within Windows with certain Intel drivers. The Intel drivers strip off the tags before it reaches the VM. Either use an external USB ethernet card such as a DLink USB 2.0 DUB-E100 (old model 10/100 not gigabit) or boot into Backtrack nativiely from a USB stick. Intel has published a registry fix, but this does not seem to work on some models: http://www.intel.com/support/network/sb/CS-005897.htm


Screen Shot    
=======================
<img src="http://www.commonexploits.com/wp-content/uploads/2012/05/new1.png" alt="Screenshot" style="max-width:100%;">

<img src="http://www.commonexploits.com/wp-content/uploads/2012/05/new2.png" alt="Screenshot" style="max-width:100%;">

Change Log
=======================

* Version 1.7 - New look, bug fixes and speed improvements.
* Version 1.5 - Official release.

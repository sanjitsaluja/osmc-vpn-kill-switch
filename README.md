### VPNKillSwitch

VPNKillSwitch is a script that can be run on a schedule using cron. It determines if (1) OpenVPN client is still connected, (2) if an internet connection is active, and (3) if the IPTables firewall rules are configured properly such that if VPN connection is lost, no data is sent or received. If any of the 3 tests fails, then the script will attempt to reconnect the client to the VPN and reconfigure the IPTables firewall rules.

### Running Script with Cron

Add the following to your root's crontab. 

`*/1 * * * * /path/to/vpnkillswitch.sh`

### Credits

This script is an adapatation of https://github.com/qbwaggle/vpnkillswitch and works on OSMC.
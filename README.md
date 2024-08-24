# VPNCONFIG LuCI module
Web UI for validating and save configuration data for number of VPN clients in UCI system.

# INSTALL
copy resources/* to /www/luci-static/resources/vpnconfig/ on target device.
copy luasrc/* to /usr/lib/lua/luci/ on target device.

# USAGE
If no configure found on target system, module will create empty file /etc/config/vpnconfig.

Valid fields of vpnconfig file sections are listed on *.htm pages.

Vpnconfig receives data from web UI, store it in UCI system and call run_backend_script() function. Real network configuration should be done inside run_backend_script().

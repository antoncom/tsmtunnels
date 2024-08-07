-- Copyright 2015 Daniel Dickinson <openwrt@daniel.thecshore.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.vpn.vpn", package.seeall)

function index()
	-- if not nixio.fs.access("/etc/config/uhttpd") then
	-- 	return
	-- end
	entry({"admin", "services", "pptp"}, cbi("vpn/pptp"), _("PPTP Client"), 30)
	entry({"admin", "services", "pptp", "action"}, call("do_pptp_action"), nil).leaf = true

	entry({"admin", "services", "l2tp"},   cbi("vpn/l2tp"),   _("L2TP Client"),   40).leaf = true
	entry({"admin", "services", "gre"},    cbi("vpn/gre"),    _("GRE Client"),    50).leaf = true
	entry({"admin", "services", "dmvpn"},  cbi("vpn/dmvpn"),  _("DMVPN Tunnels"),  60).leaf = true
	entry({"admin", "services", "eoip"},   cbi("vpn/eoip"),   _("EoIP Tunnels"),   70).leaf = true
	entry({"admin", "services", "l2tpv3"}, cbi("vpn/l2tpv3"), _("L2TPv3 Tunnels"), 80).leaf = true
	entry({"admin", "services", "ipsec"},  cbi("vpn/ipsec"),  _("IPSec Tunnels"),  90).leaf = true

end

function do_pptp_action(action, con_id)
	local commands = {
		add= function(...)
		end,

		edit = function(...)
		end,

		delete = function(...)
		end,

		enable = function(...)
		end,

		default = function(...)
			http.prepare_content("text/plain")
			http.write("0")
		end
	}

	if commands[action] then
		commands[action](con_id)
		commands["default"]()
	end
end

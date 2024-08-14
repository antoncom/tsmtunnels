-- Copyright 2015 Daniel Dickinson <openwrt@daniel.thecshore.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.vpnconfig.index", package.seeall)

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()

local dummy_cfg_content = 'config pptp \'pptp1\'\n\nconfig l2tp \'l2tp1\'\n'

function index()
	if not nixio.fs.access("/etc/config/vpnconfig") then
		nixio.fs.writefile("/etc/config/vpnconfig", dummy_cfg_content);
		return
	end

	entry({"admin", "services", "vpnconfig", "action"}, call("do_action"), nil).leaf = true
	
	entry({"admin", "services", "pptp"},   cbi("vpnconfig/pptp"),   _("PPTP Client"), 30).leaf = true
	entry({"admin", "services", "l2tp"},   cbi("vpnconfig/l2tp"),   _("L2TP Client"),   40).leaf = true
	entry({"admin", "services", "gre"},    cbi("vpnconfig/gre"),    _("GRE Client"),    50).leaf = true
	entry({"admin", "services", "dmvpn"},  cbi("vpnconfig/dmvpn"),  _("DMVPN Tunnels"),  60).leaf = true
	entry({"admin", "services", "eoip"},   cbi("vpnconfig/eoip"),   _("EoIP Tunnels"),   70).leaf = true
	entry({"admin", "services", "l2tpv3"}, cbi("vpnconfig/l2tpv3"), _("L2TPv3 Tunnels"), 80).leaf = true
	entry({"admin", "services", "ipsec"},  cbi("vpnconfig/ipsec"),  _("IPSec Tunnels"),  90).leaf = true

end

function do_action(action, vpnType)
	local name = luci.http.formvalue("name")
	local isActive = luci.http.formvalue("isActive")
	local options = luci.jsonc.parse(luci.http.formvalue("options"))
	local config = 'vpnconfig'

	local commands = {
		add= function(...)
			uci:section(config, vpnType, name, options)
			uci:set(config, name, 'isActive', 'false')
			uci:commit(config)
		end,

		edit = function(...)
			for key, value in pairs(options) do
				uci:set(config, name, key, value)
			end
			uci:commit(config)
		end,

		delete = function(...)
			uci:delete(config, name)
			uci:commit(config)
		end,

		enable = function(...)
			uci:set(config, name, 'isActive', isActive)
			uci:commit(config)
		end,

		default = function(...)
			http.prepare_content("text/plain")
			http.write(config)
		end
	}

	if commands[action] then
		commands[action](vpnType)
		commands["default"]()
	end
end

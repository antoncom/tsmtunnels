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

function do_action(action)
	local vpnType = luci.http.formvalue("type")
	local name = luci.http.formvalue("name")
	local isActive = luci.http.formvalue("isActive")
	local options = luci.jsonc.parse(luci.http.formvalue("options"))
	local config = 'vpnconfig'

	local commands = {
		add= function(...)
			uci:section(config, vpnType, name, options)
			uci:set(config, name, 'isActive', 'false')
			uci:commit(config)
			return run_backend_script(vpnType, name)
		end,

		edit = function(...)
			for key, value in pairs(options) do
				uci:set(config, name, key, value)
			end
			uci:commit(config)
			return run_backend_script(vpnType, name)
		end,

		delete = function(...)
			uci:delete(config, name)
			uci:commit(config)
			return run_backend_script(vpnType, name)
		end,

		enable = function(...)
			uci:set(config, name, 'isActive', isActive)
			uci:commit(config)
			return run_backend_script(vpnType, name)
		end
	}

	function send_response(code, message)
		local response = {}
		response.action = action
		response.message = message

		if code == 200 then
			response.status = 'success'
		else
			response.status = 'error'
		end
	
		http.status(code)
		http.prepare_content("text/json")
		http.write_json(response)
	end

	if commands[action] then
		local success = commands[action](vpnType)
		if (success) then
			send_response(200, "Configuration applyed successfully")
		else
			send_response(500, "Failed to apply configuration")
		end
	else
		send_response(400, 'Unexpected vpnconfig action')
	end
end

function run_backend_script(vpnType, name)
	-- TODO: call actual network configuration scripts
	return true -- 'true' on success, 'false' on error
end
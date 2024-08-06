local config, title = "vpn", "PPTP client"

m = Map(config, title)
m.template = "vpn/pptp"
m.pageaction = false

return m
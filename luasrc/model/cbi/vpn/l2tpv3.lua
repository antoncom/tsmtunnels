local config, title = "vpn", "L2TPv3 client"

m = Map(config, title)
m.template = "vpn/l2tpv3"
m.pageaction = false

return m
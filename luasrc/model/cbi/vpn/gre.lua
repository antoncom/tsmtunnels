local config, title = "vpn", "GRE client"

m = Map(config, title)
m.template = "vpn/gre"
m.pageaction = false

return m
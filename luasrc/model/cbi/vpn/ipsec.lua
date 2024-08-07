local config, title = "vpn", "IPSec client"

m = Map(config, title)
m.template = "vpn/ipsec"
m.pageaction = false

return m
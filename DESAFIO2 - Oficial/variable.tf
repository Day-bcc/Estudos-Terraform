variable "vnets" {
  description = "Mapa de configurações para as VNets"
  type = map(object({
    name           = string
    address_space  = string
    nsg_name       = string
    allow_ssh      = bool
    allow_peering  = bool
  }))
  default = {
    vnet1 = {
      name          = "vnet1"
      address_space = "10.1.0.0/16"
      nsg_name      = "nsg_subnet1"
      allow_ssh     = true
      allow_peering = true
    },
    vnet2 = {
      name          = "vnet2"
      address_space = "10.2.0.0/16"
      nsg_name      = "nsg_subnet2"
      allow_ssh     = true
      allow_peering = true
    }
  }
}

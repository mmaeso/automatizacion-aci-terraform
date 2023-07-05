locals {
  username = "<username>"
  password = "<password>"
  apic_url = "<url>"
}

variable "bd_map" {
  type = map(object({
    bd_subnet = string
    vrf       = string
    }
  ))
}

variable "epg_map" {
  type = map(object({
    bd       = string
    app      = string
    vlan     = string
    provides = optional(string)
    consumes = optional(string)
    }
  ))
}

variable "contract_map" {
  type = map(object({
    subject = string
    filter  = string
    scope   = string
  }))
}

variable "filter_map" {
  type = map(object({
    entry    = string
    protocol = string
    port     = string
  }))
}
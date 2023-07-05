bd_map = {
  "frontend" = {
    bd_subnet = "192.168.200.1/24"
    vrf       = "dev_vrf"
  }
  "backend" = {
    bd_subnet = "192.168.201.1/24"
    vrf       = "dev_vrf"
  }
}

epg_map = {
  "frontend_epg" = {
    bd       = "frontend"
    app      = "dev_app"
    vlan     = "vlan-200"
    provides = ""
    consumes = "permit_postgres"
  }
  "backend_epg" = {
    bd       = "backend"
    app      = "dev_app"
    vlan     = "vlan-201"
    provides = "permit_postgres"
    consumes = ""
  }
}

contract_map = {
  "permit_postgres" = {
    subject = "postgress"
    filter  = "postgres_filter"
    scope   = "tenant"
  }
}

filter_map = {
  "postgres_filter" = {
    entry    = "postgres"
    protocol = "tcp"
    port     = "5432"
  }
}
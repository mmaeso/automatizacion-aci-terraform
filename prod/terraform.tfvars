bd_map = {
  "webservers" = {
    bd_subnet = "192.168.100.1/24"
    vrf       = "prod_vrf"
  }
  "middleware" = {
    bd_subnet = "192.168.101.1/24"
    vrf       = "prod_vrf"
  }
  "db" = {
    bd_subnet = "192.168.102.1/24"
    vrf       = "prod_vrf"
  }
}

epg_map = {
  "webservers_epg" = {
    bd       = "webservers"
    app      = "prod_app"
    vlan     = "vlan-100"
    provides = "permit_web"
    consumes = "permit_app"
  }
  "middleware_epg" = {
    bd       = "middleware"
    app      = "prod_app"
    vlan     = "vlan-101"
    provides = "permit_app"
    consumes = "permit_db"
  }
  "db_epg" = {
    bd       = "db"
    app      = "prod_app"
    vlan     = "vlan-102"
    provides = "permit_db"
    consumes = ""
  }
}

contract_map = {
  "permit_db" = {
    subject = "mysql"
    filter  = "mysql_filter"
    scope   = "tenant"
  }
  "permit_app" = {
    subject = "app"
    filter  = "app_filter"
    scope   = "tenant"
  }
  "permit_web" = {
    subject = "web"
    filter  = "web_filter"
    scope   = "global"
  }
}

filter_map = {
  "mysql_filter" = {
    entry    = "mysql"
    protocol = "tcp"
    port     = "3306"
  }
  "app_filter" = {
    entry    = "middleware"
    protocol = "tcp"
    port     = "8080"
  }
  "web_filter" = {
    entry    = "https"
    protocol = "tcp"
    port     = "443"
  }
}
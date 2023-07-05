provider "aci" {
  username = local.username
  password = local.password
  url      = local.apic_url
  insecure = true
}

resource "aci_tenant" "prod_tenant" {
  name        = "PROD"
  description = "Production Tenant"
}

resource "aci_vrf" "prod_vrf" {
  tenant_dn = aci_tenant.prod_tenant.id
  name      = "prod_vrf"
}

resource "aci_bridge_domain" "prod_bd" {
  for_each           = var.bd_map
  tenant_dn          = aci_tenant.prod_tenant.id
  relation_fv_rs_ctx = aci_vrf.prod_vrf.id
  name               = each.key
}

resource "aci_subnet" "prod_bdsubnet" {
  for_each  = var.bd_map
  parent_dn = aci_bridge_domain.prod_bd[each.key].id
  scope     = ["public"]
  ip        = each.value.bd_subnet
  ctrl      = ["unspecified"]
}

resource "aci_application_profile" "prod_app" {
  name      = "prod_app"
  tenant_dn = aci_tenant.prod_tenant.id
}

resource "aci_application_epg" "prod_epg" {
  for_each               = var.epg_map
  name                   = each.key
  relation_fv_rs_bd      = aci_bridge_domain.prod_bd[each.value.bd].id
  application_profile_dn = aci_application_profile.prod_app.id
}

resource "aci_epg_to_domain" "prod_epg_to_domain" {
  for_each           = var.epg_map
  application_epg_dn = aci_application_epg.prod_epg[each.key].id
  tdn                = aci_physical_domain.prod_domain.id
}


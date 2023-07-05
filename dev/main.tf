provider "aci" {
  username = local.username
  password = local.password
  url      = local.apic_url
  insecure = true
}

resource "aci_tenant" "dev_tenant" {
  name        = "DEV"
  description = "Developer Tenant. Creado por Terraform"
}

resource "aci_vrf" "dev_vrf" {
  tenant_dn = aci_tenant.dev_tenant.id
  name      = "dev_vrf"
}

resource "aci_bridge_domain" "dev_bd" {
  for_each           = var.bd_map
  tenant_dn          = aci_tenant.dev_tenant.id
  relation_fv_rs_ctx = aci_vrf.dev_vrf.id
  name               = each.key
}

resource "aci_subnet" "dev_bdsubnet" {
  for_each  = var.bd_map
  parent_dn = aci_bridge_domain.dev_bd[each.key].id
  scope     = ["public"]
  ip        = each.value.bd_subnet
  ctrl      = ["unspecified"]
}

resource "aci_application_profile" "dev_app" {
  name      = "dev_app"
  tenant_dn = aci_tenant.dev_tenant.id
}

resource "aci_application_epg" "dev_epg" {
  for_each               = var.epg_map
  name                   = each.key
  relation_fv_rs_bd      = aci_bridge_domain.dev_bd[each.value.bd].id
  application_profile_dn = aci_application_profile.dev_app.id
}

resource "aci_epg_to_domain" "dev_epg_to_domain" {
  for_each           = var.epg_map
  application_epg_dn = aci_application_epg.dev_epg[each.key].id
  tdn                = aci_physical_domain.dev_domain.id
}


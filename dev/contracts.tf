resource "aci_filter" "dev_filter" {
  for_each  = var.filter_map
  tenant_dn = aci_tenant.dev_tenant.id
  name      = each.key
}

resource "aci_filter_entry" "dev_filter_entry" {
  for_each    = var.filter_map
  filter_dn   = aci_filter.dev_filter[each.key].id
  name        = each.value.entry
  ether_t     = "ipv4"
  prot        = each.value.protocol
  d_from_port = each.value.port
  d_to_port   = each.value.port
}

resource "aci_contract" "dev_contract" {
  for_each  = var.contract_map
  tenant_dn = aci_tenant.dev_tenant.id
  name      = each.key
}

resource "aci_contract_subject" "dev_contract_subject" {
  for_each                     = var.contract_map
  contract_dn                  = aci_contract.dev_contract[each.key].id
  name                         = each.value.subject
  relation_vz_rs_subj_filt_att = [aci_filter.dev_filter[each.value.filter].id]
}

resource "aci_epg_to_contract" "dev_epg_provided_contract" {
  for_each           = { for k, v in var.epg_map : k => v if v.provides != "" }
  application_epg_dn = aci_application_epg.dev_epg[each.key].id
  contract_type      = "provider"
  contract_dn        = aci_contract.dev_contract[each.value.provides].id
}

resource "aci_epg_to_contract" "dev_epg_consumed_contract" {
  for_each           = { for k, v in var.epg_map : k => v if v.consumes != "" }
  application_epg_dn = aci_application_epg.dev_epg[each.key].id
  contract_type      = "consumer"
  contract_dn        = aci_contract.dev_contract[each.value.consumes].id
}

data "aci_tenant" "prod_tenant" {
  name = "PROD"
}

data "aci_contract" "prod_imported_contract" {
  tenant_dn = data.aci_tenant.prod_tenant.id
  name      = "permit_web"
}

resource "aci_imported_contract" "prod_permit_web" {
  tenant_dn         = aci_tenant.dev_tenant.id
  name              = "PROD_permit_web"
  relation_vz_rs_if = data.aci_contract.prod_imported_contract.id
}

resource "aci_epg_to_contract_interface" "dev_consumed_imported_contract" {
  application_epg_dn = aci_application_epg.dev_epg["frontend_epg"].id
  contract_interface_dn = aci_imported_contract.prod_permit_web.id
}
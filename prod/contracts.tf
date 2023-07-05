resource "aci_filter" "prod_filter" {
  for_each  = var.filter_map
  tenant_dn = aci_tenant.prod_tenant.id
  name      = each.key
}

resource "aci_filter_entry" "prod_filter_entry" {
  for_each    = var.filter_map
  filter_dn   = aci_filter.prod_filter[each.key].id
  name        = each.value.entry
  ether_t     = "ipv4"
  prot        = each.value.protocol
  d_from_port = each.value.port
  d_to_port   = each.value.port
}

resource "aci_contract" "prod_contract" {
  for_each  = var.contract_map
  tenant_dn = aci_tenant.prod_tenant.id
  name      = each.key
  scope     = each.value.scope
}

resource "aci_contract_subject" "prod_contract_subject" {
  for_each                     = var.contract_map
  contract_dn                  = aci_contract.prod_contract[each.key].id
  name                         = each.value.subject
  relation_vz_rs_subj_filt_att = [aci_filter.prod_filter[each.value.filter].id]
}

resource "aci_epg_to_contract" "prod_epg_provided_contract" {
  for_each           = var.epg_map
  application_epg_dn = aci_application_epg.prod_epg[each.key].id
  contract_type      = "provider"
  contract_dn        = aci_contract.prod_contract[each.value.provides].id
}

resource "aci_epg_to_contract" "prod_epg_consumed_contract" {
  for_each           = { for k, v in var.epg_map : k => v if v.consumes != "" }
  application_epg_dn = aci_application_epg.prod_epg[each.key].id
  contract_type      = "consumer"
  contract_dn        = aci_contract.prod_contract[each.value.consumes].id
}
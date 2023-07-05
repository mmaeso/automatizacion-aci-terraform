resource "aci_vlan_pool" "prod_vlan_pool" {
  name       = "prod_vlan_pool"
  alloc_mode = "static"
}

resource "aci_ranges" "prod_vlan_pool_range" {
  vlan_pool_dn = aci_vlan_pool.prod_vlan_pool.id
  from         = "vlan-2"
  to           = "vlan-1000"
  alloc_mode   = "static"
}

resource "aci_physical_domain" "prod_domain" {
  name                      = "prod_domain"
  relation_infra_rs_vlan_ns = aci_vlan_pool.prod_vlan_pool.id
}


resource "aci_attachable_access_entity_profile" "prod_aaep" {
  name = "Prod_AAEP"
}

resource "aci_aaep_to_domain" "aaep_to_domain" {
  attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.prod_aaep.id
  domain_dn                           = aci_physical_domain.prod_domain.id
}

resource "aci_leaf_access_bundle_policy_group" "intpol_vpc_domain_10" {
  lag_t                       = "node"
  name                        = "intpol_vpc_domain_10"
  relation_infra_rs_att_ent_p = aci_attachable_access_entity_profile.prod_aaep.id
}

resource "aci_leaf_interface_profile" "prod_interface_profile" {
  name = "prod_interface_profile"
}

resource "aci_leaf_profile" "prod_leaf_profile" {
  name                         = "prod_leaf_profile"
  relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.prod_interface_profile.id]
  leaf_selector {
    name                    = "Leafs"
    switch_association_type = "range"
    node_block {
      name  = "leaf1-leaf2"
      from_ = "1001"
      to_   = "1002"
    }
  }
}

resource "aci_access_port_selector" "vpc_port_selector" {
  leaf_interface_profile_dn      = aci_leaf_interface_profile.prod_interface_profile.id
  name                           = "prod_vpc_port_selector"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_bundle_policy_group.intpol_vpc_domain_10.id
}

resource "aci_access_port_block" "vpc_port_block" {
  access_port_selector_dn = aci_access_port_selector.vpc_port_selector.id
  name                    = "vpc_1_port_block"
  from_card               = "1"
  from_port               = "1"
  to_card                 = "1"
  to_port                 = "1"
}
resource "aci_vpc_explicit_protection_group" "vpc_domain_10" {
  name                             = "vpc_domain_10"
  switch1                          = aci_leaf_profile.prod_leaf_profile.leaf_selector[0].node_block[0].from_
  switch2                          = aci_leaf_profile.prod_leaf_profile.leaf_selector[0].node_block[0].to_
  vpc_explicit_protection_group_id = 10
  vpc_domain_policy                = "default"
}

resource "aci_epg_to_static_path" "prod_static_ports" {
  for_each           = var.epg_map
  application_epg_dn = aci_application_epg.prod_epg[each.key].id
  encap              = each.value.vlan
  tdn                = "topology/pod-1/protpaths-1001-1002/pathep-[${aci_leaf_access_bundle_policy_group.intpol_vpc_domain_10.name}]"
}
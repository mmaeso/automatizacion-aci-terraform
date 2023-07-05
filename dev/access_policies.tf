resource "aci_vlan_pool" "dev_vlan_pool" {
  name       = "dev_vlan_pool"
  alloc_mode = "static"
}

resource "aci_ranges" "dev_vlan_pool_range" {
  vlan_pool_dn = aci_vlan_pool.dev_vlan_pool.id
  from         = "vlan-1001"
  to           = "vlan-1500"
  alloc_mode   = "static"
}

resource "aci_physical_domain" "dev_domain" {
  name                      = "dev_domain"
  relation_infra_rs_vlan_ns = aci_vlan_pool.dev_vlan_pool.id
}


resource "aci_attachable_access_entity_profile" "dev_aaep" {
  name = "Dev_AAEP"
}

resource "aci_aaep_to_domain" "dev_aaep_to_domain" {
  attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.dev_aaep.id
  domain_dn                           = aci_physical_domain.dev_domain.id
}

resource "aci_leaf_access_bundle_policy_group" "intpol_vpc2" {
  lag_t                       = "node"
  name                        = "intpol_vpc2"
  relation_infra_rs_att_ent_p = aci_attachable_access_entity_profile.dev_aaep.id
}

resource "aci_leaf_interface_profile" "dev_interface_profile" {
  name = "dev_interface_profile"
}

resource "aci_leaf_profile" "dev_leaf_profile" {
  name                         = "dev_leaf_profile"
  relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.dev_interface_profile.id]
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
  leaf_interface_profile_dn      = aci_leaf_interface_profile.dev_interface_profile.id
  name                           = "dev_vpc_port_selector"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_bundle_policy_group.intpol_vpc2.id
}

resource "aci_access_port_block" "vpc2_port_block" {
  access_port_selector_dn = aci_access_port_selector.vpc_port_selector.id
  name                    = "vpc2_port_block"
  from_card               = "1"
  from_port               = "2"
  to_card                 = "1"
  to_port                 = "2"
}

#resource "aci_vpc_explicit_protection_group" "vpc_domain_10" {
#  name                             = "vpc_domain_10"
#  switch1                          = aci_leaf_profile.dev_leaf_profile.leaf_selector[0].node_block[0].from_
#  switch2                          = aci_leaf_profile.dev_leaf_profile.leaf_selector[0].node_block[0].to_
#  vpc_explicit_protection_group_id = 10
#  vpc_domain_policy                = "default"
#}

resource "aci_epg_to_static_path" "dev_static_ports" {
  for_each           = var.epg_map
  application_epg_dn = aci_application_epg.dev_epg[each.key].id
  encap              = each.value.vlan
  tdn                = "topology/pod-1/protpaths-1001-1002/pathep-[${aci_leaf_access_bundle_policy_group.intpol_vpc2.name}]"
}
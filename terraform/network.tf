# Rede privada: sem IP publico e sem ingress. Saida via NAT (sem custo na OCI)
# para pacotes e para o Oracle Cloud Agent publicar metricas.
resource "oci_core_vcn" "homolog" {
  compartment_id = oci_identity_compartment.homolog.id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "vcn-zabbix-homolog"
  dns_label      = "zbxhomolog"
  freeform_tags  = local.tags
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = oci_identity_compartment.homolog.id
  vcn_id         = oci_core_vcn.homolog.id
  display_name   = "natgw-zabbix-homolog"
  freeform_tags  = local.tags
}

resource "oci_core_route_table" "private" {
  compartment_id = oci_identity_compartment.homolog.id
  vcn_id         = oci_core_vcn.homolog.id
  display_name   = "rt-zabbix-homolog-private"
  freeform_tags  = local.tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = oci_identity_compartment.homolog.id
  vcn_id         = oci_core_vcn.homolog.id
  display_name   = "sl-zabbix-homolog-private"
  freeform_tags  = local.tags

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  # Sem ingress rules de proposito
}

resource "oci_core_subnet" "private" {
  compartment_id             = oci_identity_compartment.homolog.id
  vcn_id                     = oci_core_vcn.homolog.id
  cidr_block                 = var.subnet_cidr
  display_name               = "snet-zabbix-homolog-private"
  dns_label                  = "priv"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  freeform_tags              = local.tags
}

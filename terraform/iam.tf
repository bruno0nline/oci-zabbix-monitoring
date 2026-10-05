locals {
  tags = var.freeform_tags

  # Recursos lidos pelo template "Oracle Cloud by HTTP" (doc oficial Zabbix)
  zabbix_public_key = (
    var.zabbix_public_key != "" ? var.zabbix_public_key :
    var.zabbix_public_key_path != "" ? file(pathexpand(var.zabbix_public_key_path)) : ""
  )

  zabbix_read_resources = [
    "metrics",
    "instances",
    "vnic-attachments",
    "vcns",
    "subnets",
    "volumes",
    "buckets",
    "autonomous-databases",
  ]
}

resource "oci_identity_compartment" "homolog" {
  compartment_id = var.tenancy_ocid
  name           = var.compartment_name
  description    = "Homologacao Zabbix x OCI - recursos de teste (temporario)"
  enable_delete  = true
  freeform_tags  = local.tags
}

# Grupo criado no Default identity domain (mesmo dominio do svc-zabbix)
resource "oci_identity_group" "zabbix" {
  compartment_id = var.tenancy_ocid
  name           = "grp-zabbix-monitoring-ro"
  description    = "Zabbix - acesso somente leitura para monitoramento"
  freeform_tags  = local.tags
}

resource "oci_identity_user_group_membership" "zabbix" {
  group_id = oci_identity_group.zabbix.id
  user_id  = var.zabbix_user_ocid
}

# Least privilege: leitura apenas no compartment de homologacao
resource "oci_identity_policy" "zabbix_read" {
  compartment_id = var.tenancy_ocid
  name           = "pol-zabbix-monitoring-ro"
  description    = "Zabbix read-only no compartment de homologacao"
  freeform_tags  = local.tags

  statements = concat(
    [for r in local.zabbix_read_resources :
      "Allow group ${oci_identity_group.zabbix.name} to read ${r} in compartment ${oci_identity_compartment.homolog.name}"
    ],
    # namespace do Object Storage so existe no nivel da tenancy
    ["Allow group ${oci_identity_group.zabbix.name} to read objectstorage-namespaces in tenancy"]
  )
}

# Necessaria para o Object Storage executar lifecycle policy no bucket
resource "oci_identity_policy" "objectstorage_service" {
  compartment_id = var.tenancy_ocid
  name           = "pol-objectstorage-lifecycle-zabbix-homolog"
  description    = "Permite ao servico Object Storage aplicar lifecycle no compartment de homologacao"
  freeform_tags  = local.tags

  statements = [
    "Allow service objectstorage-${var.region} to manage object-family in compartment ${oci_identity_compartment.homolog.name}"
  ]
}

# Opcional: upload da chave publica do Igo (fingerprint sai no output)
resource "oci_identity_api_key" "zabbix" {
  count     = local.zabbix_public_key == "" ? 0 : 1
  user_id   = var.zabbix_user_ocid
  key_value = trimspace(local.zabbix_public_key)
}

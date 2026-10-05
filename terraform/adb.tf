resource "random_password" "adb_admin" {
  count            = var.enable_adb ? 1 : 0
  length           = 20
  special          = true
  override_special = "#_"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 1
}

# Always Free: 1 OCPU / 20 GB. Para automaticamente apos 7 dias sem uso.
resource "oci_database_autonomous_database" "homolog" {
  count                    = var.enable_adb ? 1 : 0
  compartment_id           = oci_identity_compartment.homolog.id
  db_name                  = "zbxhomolog"
  display_name             = "adb-zabbix-homolog"
  db_workload              = "OLTP"
  is_free_tier             = true
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  admin_password           = random_password.adb_admin[0].result

  # Acesso restrito a VCN de homologacao (ninguem precisa conectar; o Zabbix le via API)
  is_mtls_connection_required = true
  whitelisted_ips             = [oci_core_vcn.homolog.id]

  freeform_tags = local.tags
}

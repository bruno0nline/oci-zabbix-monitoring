output "zabbix_macros" {
  description = "Valores para enviar ao Igo (nenhum segredo aqui)."
  value = {
    "{$OCI.API.TENANCY}"                 = var.tenancy_ocid
    "{$OCI.API.USER}"                    = var.zabbix_user_ocid
    "{$OCI.API.FINGERPRINT}"             = local.zabbix_public_key == "" ? "upload manual pendente" : oci_identity_api_key.zabbix[0].fingerprint
    "{$OCI.API.CORE.HOST}"               = "iaas.${var.region}.oraclecloud.com"
    "{$OCI.API.TELEMETRY.HOST}"          = "telemetry.${var.region}.oraclecloud.com"
    "{$OCI.API.OBJECT.STORAGE.HOST}"     = "objectstorage.${var.region}.oraclecloud.com"
    "{$OCI.API.AUTONOMOUS.DB.HOST}"      = "database.${var.region}.oraclecloud.com"
    "{$OCI.API.COMPARTMENT.COMPUTE}"     = oci_identity_compartment.homolog.id
    "{$OCI.API.COMPARTMENT.VCN}"         = oci_identity_compartment.homolog.id
    "{$OCI.API.COMPARTMENT.VOLUME.BLOCK}" = oci_identity_compartment.homolog.id
    "{$OCI.API.COMPARTMENT.VOLUME.BOOT}" = oci_identity_compartment.homolog.id
    "{$OCI.API.COMPARTMENT.OBJECT.STORAGE}" = oci_identity_compartment.homolog.id
    "{$OCI.API.COMPARTMENT.AUTONOMOUS.DB}" = oci_identity_compartment.homolog.id
  }
}

output "recursos_criados" {
  value = {
    instance = oci_core_instance.vm.id
    volume   = oci_core_volume.data.id
    bucket   = oci_objectstorage_bucket.homolog.name
    vcn      = oci_core_vcn.homolog.id
    adb      = var.enable_adb ? oci_database_autonomous_database.homolog[0].id : "desabilitado"
  }
}

output "adb_admin_password" {
  description = "terraform output -raw adb_admin_password"
  value       = var.enable_adb ? random_password.adb_admin[0].result : null
  sensitive   = true
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "homolog" {
  compartment_id = oci_identity_compartment.homolog.id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "bkt-zabbix-homolog"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = "Disabled"
  freeform_tags  = local.tags
}

# Alterar esta regra durante o teste dispara a trigger
# "Object lifecycle management policy has changed" no Zabbix
resource "oci_objectstorage_object_lifecycle_policy" "homolog" {
  namespace = data.oci_objectstorage_namespace.ns.namespace
  bucket    = oci_objectstorage_bucket.homolog.name

  rules {
    name        = "delete-after-30d"
    action      = "DELETE"
    is_enabled  = true
    target      = "objects"
    time_amount = 30
    time_unit   = "DAYS"
  }

  depends_on = [oci_identity_policy.objectstorage_service]
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  ad_name  = data.oci_identity_availability_domains.ads.availability_domains[0].name
  is_flex  = length(regexall("Flex$", var.instance_shape)) > 0
}

resource "oci_core_instance" "vm" {
  availability_domain = local.ad_name
  compartment_id      = oci_identity_compartment.homolog.id
  display_name        = "vm-zabbix-homolog-01"
  shape               = var.instance_shape
  freeform_tags       = local.tags

  dynamic "shape_config" {
    for_each = local.is_flex ? [1] : []
    content {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_gbs
    }
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.oracle_linux.images[0].id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    display_name     = "vnic-zabbix-homolog-01"
  }

  # Gera carga de CPU/memoria/disco a cada hora para validar graficos no Zabbix
  metadata = {
    user_data = base64encode(file("${path.module}/cloud-init.yaml"))
  }

  # Plugin que publica as metricas oci_computeagent (CPU, memoria, disco, rede)
  agent_config {
    is_monitoring_disabled = false
    is_management_disabled = false

    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = "ENABLED"
    }
  }
}

resource "oci_core_volume" "data" {
  availability_domain = local.ad_name
  compartment_id      = oci_identity_compartment.homolog.id
  display_name        = "bv-zabbix-homolog-01"
  size_in_gbs         = 50
  vpus_per_gb         = 10
  freeform_tags       = local.tags
}

resource "oci_core_volume_attachment" "data" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm.id
  volume_id       = oci_core_volume.data.id
  device          = "/dev/oracleoci/oraclevdb"
  display_name    = "att-bv-zabbix-homolog-01"
}

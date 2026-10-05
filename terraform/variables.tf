variable "tenancy_ocid" {
  description = "OCID da tenancy BS4IT."
  type        = string
}

variable "region" {
  description = "Regiao dos recursos de teste. Always Free so existe na home region (VCP = sa-vinhedo-1)."
  type        = string
  default     = "sa-vinhedo-1"
}

variable "oci_profile" {
  description = "Perfil do ~/.oci/config (execucao local). null = auth nativa do Cloud Shell / Resource Manager."
  type        = string
  default     = null
}

variable "zabbix_user_ocid" {
  description = "OCID do usuario de servico svc-zabbix (Default identity domain)."
  type        = string
}

variable "zabbix_public_key" {
  description = "Conteudo PEM da chave PUBLICA do svc-zabbix (usado no Resource Manager). Vazio = sem upload."
  type        = string
  default     = ""
}

variable "zabbix_public_key_path" {
  description = "Alternativa local/Cloud Shell: caminho do arquivo da chave PUBLICA."
  type        = string
  default     = ""
}

variable "compartment_name" {
  description = "Compartment isolado para a homologacao."
  type        = string
  default     = "cmp-zabbix-homolog"
}

variable "vcn_cidr" {
  type    = string
  default = "10.80.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.80.1.0/24"
}

variable "instance_shape" {
  description = "Always Free: VM.Standard.E2.1.Micro (x86) ou VM.Standard.A1.Flex (ARM)."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_ocpus" {
  description = "Usado apenas em shapes Flex."
  type        = number
  default     = 1
}

variable "instance_memory_gbs" {
  description = "Usado apenas em shapes Flex."
  type        = number
  default     = 6
}

variable "enable_adb" {
  description = "Cria um Autonomous Database Always Free para testar o template de ADB."
  type        = bool
  default     = true
}

variable "freeform_tags" {
  description = "Tags aplicadas em todos os recursos (usadas no filtro de discovery do Zabbix)."
  type        = map(string)
  default = {
    monitoring = "zabbix"
    projeto    = "homolog-zabbix-oci"
    ambiente   = "homolog"
    owner      = "cloud-bs4it"
  }
}

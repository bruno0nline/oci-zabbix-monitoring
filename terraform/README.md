# Terraform — Homologação Zabbix x OCI

## Execução via OCI Resource Manager (recomendado)

1. **Developer Services → Resource Manager → Configuration Source Providers → Create**
   - Tipo: GitHub · Server URL: `https://github.com/`
   - Token: GitHub *fine-grained PAT*, só este repositório, permissão **Contents: Read-only**, com expiração.
2. **Stacks → Create Stack → Source Code Control System**
   - Provider criado no passo 1 · Repositório · Branch `main`
   - **Working directory: `terraform`** · Terraform version: **1.5.x**
   - Compartment do stack: root (o stack cria o próprio compartment).
3. Preencha o formulário (gerado pelo `schema.yaml`): OCID do `svc-zabbix` e chave **pública** PEM.
4. **Plan** → revisar (≈17 recursos para criar, 0 para alterar/destruir) → **Apply**.
5. Aba **Outputs** do job de apply → `zabbix_macros` (enviar ao time Zabbix).

Vantagens: state gerenciado pela OCI (com lock), histórico de jobs e logs, drift detection,
execução com as permissões do usuário que dispara o job.

## Execução local / Cloud Shell

```bash
cp terraform.tfvars.example terraform.tfvars   # preencher
terraform init && terraform validate
terraform plan -out tfplan && terraform apply tfplan
terraform output zabbix_macros
```

> Use **apenas um** modo de execução. Cada modo tem seu próprio state; aplicar nos dois
> gera conflito de nomes.

## O que é criado

| Camada | Recurso | Nome |
|---|---|---|
| IAM | Compartment | `cmp-zabbix-homolog` |
| IAM | Grupo + vínculo do usuário de serviço | `grp-zabbix-monitoring-ro` |
| IAM | Policy read-only (escopo compartment) | `pol-zabbix-monitoring-ro` |
| IAM | Policy do serviço Object Storage (lifecycle) | `pol-objectstorage-lifecycle-zabbix-homolog` |
| IAM | API key do usuário de serviço (opcional) | — |
| Rede | VCN + subnet privada + NAT GW (sem ingress) | `vcn-zabbix-homolog` |
| Compute | VM Oracle Linux 9 + carga horária (stress-ng/fio) | `vm-zabbix-homolog-01` |
| Storage | Block volume 50 GB anexado | `bv-zabbix-homolog-01` |
| Storage | Bucket privado + lifecycle 30d | `bkt-zabbix-homolog` |
| DB | Autonomous DB Always Free (opcional) | `adb-zabbix-homolog` |

Custo esperado: **zero** (Always Free na home region + NAT Gateway sem custo).

## Desmontagem

```bash
oci os object bulk-delete -ns <NAMESPACE> -bn bkt-zabbix-homolog --force   # esvaziar o bucket
```
Depois: **Resource Manager → Stack → Destroy** (ou `terraform destroy` se rodou localmente).
A exclusão do compartment é assíncrona.

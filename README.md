# OCI Monitoring with Zabbix — Lab as Code

Terraform lab that provisions a **zero-cost (Always Free)**, isolated OCI environment and a
**least-privilege, read-only service identity** to validate Zabbix's official
[Oracle Cloud by HTTP](https://www.zabbix.com/integrations/oracle_cloud) template.

```
OCI Tenancy (home region)
 ├─ IAM: svc user (API key only) → grp-zabbix-monitoring-ro → read-only policy (1 compartment)
 └─ cmp-zabbix-homolog
     ├─ VCN + private subnet + NAT (no ingress)
     ├─ VM (Oracle Linux 9, hourly synthetic CPU/IO load)
     ├─ Block volume · Bucket (+ lifecycle) · Autonomous DB (Free)
                 ▲
   HTTPS 443 (signed API requests: discovery + Monitoring MQL)
                 │
            Zabbix Server/Proxy ── template "Oracle Cloud by HTTP"
```

## Highlights

- **Security:** dedicated service user with API key only, no console access, read-only policy
  scoped to a single compartment, private key never handled by Terraform.
- **Automation:** deploy/destroy via OCI Resource Manager (managed Terraform) with a guided
  form (`schema.yaml`), or locally.
- **Cost:** 100% Always Free resources; synthetic load via cloud-init to validate dashboards.
- **Coverage tested:** Compute, Networking, Block/Boot Volume, Object Storage, Autonomous DB.

See [`terraform/README.md`](terraform/README.md) for deployment steps (PT-BR).

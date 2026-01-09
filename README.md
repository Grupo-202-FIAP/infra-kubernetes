# Infra-Kubernetes - Cluster EKS de Baixo Custo

Repositório Terraform para provisionar um cluster Amazon EKS (Elastic Kubernetes Service) otimizado para baixo custo, incluindo integração com Datadog, ArgoCD para GitOps, e controles de recursos.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Configuração](#configuração)
- [Uso](#uso)
- [Componentes](#componentes)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Variáveis](#variáveis)
- [Outputs](#outputs)
- [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

Este projeto cria uma infraestrutura Kubernetes completa na AWS com foco em:

- **Baixo Custo**: Configuração otimizada com instâncias t3.medium e node groups fixos
- **Monitoramento**: Integração com Datadog para métricas, logs e APM
- **GitOps**: ArgoCD para gerenciamento declarativo de aplicações
- **Segurança**: External Secrets Operator para gerenciamento seguro de secrets via AWS SSM
- **Controle de Recursos**: LimitRange e ResourceQuota para otimização de custos
- **IRSA**: IAM Roles for Service Accounts para segurança e controle de acesso

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS EKS Cluster                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   ArgoCD     │  │  Datadog     │  │ External     │       │
│  │  (GitOps)    │  │ (Monitoring) │  │  Secrets     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ AWS LB       │  │  EBS CSI     │  │  Metrics     │       │
│  │ Controller   │  │   Driver     │  │   Server     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Node Group (t3.medium x 2)                   │   │
│  │  ┌────────────┐  ┌────────────┐                      │   │
│  │  │   Node 1   │  │   Node 2   │                      │   │
│  │  └────────────┘  └────────────┘                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
    ┌─────────┐         ┌─────────┐         ┌─────────┐
    │  AWS    │         │  AWS    │         │  AWS    │
    │   SSM   │         │   IAM   │         │   VPC   │
    │(Secrets)│         │ (IRSA)  │         │(Remote) │
    └─────────┘         └─────────┘         └─────────┘
```

## 📦 Pré-requisitos

### Ferramentas Necessárias

- **Terraform** >= 1.5.0
- **AWS CLI** configurado com credenciais apropriadas
- **kubectl** (para interagir com o cluster após criação)
- **helm** (opcional, para gerenciar charts manualmente)

### Recursos AWS Necessários

1. **VPC e Subnets**: O projeto espera um state remoto do Terraform com:
   - Output: `public_subnet_ids` (lista de IDs das subnets públicas)
   - State remoto configurado em `data.tf`

2. **IAM Roles**: Duas IAM Roles devem existir:
   - **Cluster Role**: Para o serviço EKS
   - **Node Role**: Para os nodes do EKS
   - Ambas devem ter as policies necessárias para EKS

3. **Parâmetro SSM**: Criar o parâmetro para a API key do Datadog:
   ```bash
   aws ssm put-parameter \
     --name "/datadog/api-key" \
     --value "sua-api-key-datadog" \
     --type "SecureString" \
     --region us-east-1
   ```

4. **State Remoto**: S3 bucket configurado para o state do Terraform:
   - Bucket: `terraform-state-bucket-nextime`
   - Key: `infra.tfstate`
   - Região: `us-east-1`

## ⚙️ Configuração

### 1. Clone o Repositório

```bash
git clone https://github.com/Grupo-202-FIAP/infra-kubernetes
cd infra-kubernetes
```

### 2. Configure as Variáveis

Edite o arquivo `infra/terraform/terraform.tfvars` com seus valores:

```hcl
aws_region          = "us-east-1"
environment         = "dev"
cluster_name        = "meu-cluster-eks"
cluster_version     = "1.28"
node_role_arn       = "arn:aws:iam::ACCOUNT_ID:role/NodeRole"
cluster_role_arn    = "arn:aws:iam::ACCOUNT_ID:role/ClusterRole"
node_min_size       = 2
node_max_size       = 2
node_desired_size   = 2
node_instance_types = ["t3.medium"]
tags = {
  Environment = "dev"
  Project     = "meu-projeto"
}
endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["0.0.0.0/0"]  # Ajuste para seus IPs
```

### 3. Configure o State Remoto (se necessário)

Edite `infra/terraform/data.tf` para apontar para seu bucket S3:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "seu-bucket-terraform-state"
    key    = "infra.tfstate"
    region = "us-east-1"
  }
}
```

## 🚀 Uso

### Inicialização

```bash
cd infra/terraform
terraform init
```

### Validação

```bash
terraform validate
terraform fmt
```

### Planejamento

```bash
terraform plan
```

### Aplicação

```bash
terraform apply
```

### Destruição (Cuidado!)

```bash
terraform destroy
```

## 🔧 Componentes

### 1. EKS Cluster
- Versão Kubernetes configurável (padrão: 1.28)
- Endpoint público e privado configuráveis
- OIDC Provider habilitado para IRSA

### 2. Node Group
- Tipo de instância: t3.medium (otimizado para custo)
- Tamanho fixo (min/max/desired configuráveis)
- Auto-scaling desabilitado para controle de custos

### 3. ArgoCD
- Instalado via Helm no namespace `argocd`
- GitOps para gerenciamento declarativo de aplicações
- Acesso via port-forward ou LoadBalancer (configurar conforme necessário)

### 4. Datadog
- Agent instalado via Helm no namespace `datadog`
- Integração com:
  - **APM**: Application Performance Monitoring
  - **Logs**: Coleta de logs de containers
  - **Metrics**: Métricas do cluster e aplicações
- API Key gerenciada via External Secrets (SSM)

### 5. External Secrets Operator
- Gerencia secrets do Kubernetes a partir do AWS SSM
- Service Account com IRSA para acesso seguro
- SecretStore e ExternalSecret configurados para Datadog

### 6. AWS Load Balancer Controller
- Gerencia Application Load Balancers e Network Load Balancers
- Integração com Ingress resources do Kubernetes
- IRSA configurado para permissões AWS

### 7. EBS CSI Driver
- Provisionamento dinâmico de volumes EBS
- Suporte a PersistentVolumes e PersistentVolumeClaims
- IRSA configurado

### 8. Metrics Server
- Coleta métricas de recursos (CPU/Memory) dos pods
- Necessário para HPA (Horizontal Pod Autoscaler)
- Instalado no namespace `kube-system`

### 9. Controles de Recursos
- **LimitRange**: Limites padrão para containers no namespace `default`
  - CPU: 500m (limit), 200m (request)
  - Memory: 512Mi (limit), 256Mi (request)
- **ResourceQuota**: Quotas para o namespace `default`
  - CPU: 2 (requests), 4 (limits)
  - Memory: 2Gi (requests), 4Gi (limits)

## 📁 Estrutura do Projeto

```
infra-kubernetes/
├── README.md
├── infra/
│   ├── terraform/
│   │   ├── main.tf                 # Módulo EKS
│   │   ├── variables.tf            # Variáveis do root module
│   │   ├── outputs.tf              # Outputs do root module
│   │   ├── providers.tf            # Configuração dos providers
│   │   ├── data.tf                  # Data sources (remote state)
│   │   ├── terraform.tfvars        # Valores das variáveis
│   │   ├── addons.tf                # Helm releases (ArgoCD, Datadog, etc)
│   │   ├── irsa.tf                  # IAM Roles e Policies (IRSA)
│   │   ├── k8s-manifests.tf         # Manifests Kubernetes (Limits, Secrets)
│   │   └── modules/
│   │       └── eks/
│   │           ├── main.tf          # Recursos EKS (cluster, node group)
│   │           ├── variables.tf     # Variáveis do módulo
│   │           ├── outputs.tf       # Outputs do módulo (incluindo OIDC)
│   │           └── oidc.tf          # OIDC Provider
│   └── k8s/                         # Manifests Kubernetes (opcional)
│       ├── external-secrets/
│       └── limits/
└── deploy.sh                        # Script de deploy (legado)
```

## 📝 Variáveis

### Variáveis Principais

| Variável | Tipo | Descrição | Padrão |
|----------|------|-----------|--------|
| `cluster_name` | string | Nome do cluster EKS | - |
| `environment` | string | Ambiente (dev/staging/prod) | - |
| `cluster_version` | string | Versão do Kubernetes | - |
| `cluster_role_arn` | string | ARN da IAM Role do cluster | - |
| `node_role_arn` | string | ARN da IAM Role dos nodes | - |
| `node_min_size` | number | Tamanho mínimo do node group | - |
| `node_max_size` | number | Tamanho máximo do node group | - |
| `node_desired_size` | number | Tamanho desejado do node group | - |
| `node_instance_types` | list(string) | Tipos de instância EC2 | - |
| `endpoint_private_access` | bool | Habilita endpoint privado | - |
| `endpoint_public_access` | bool | Habilita endpoint público | - |
| `public_access_cidrs` | list(string) | CIDRs para acesso público | - |
| `tags` | map(string) | Tags adicionais | - |

## 📤 Outputs

O módulo EKS expõe os seguintes outputs:

- `cluster_name`: Nome do cluster
- `cluster_endpoint`: Endpoint do cluster
- `cluster_certificate_authority_data`: Certificado CA do cluster
- `oidc_provider_arn`: ARN do OIDC Provider
- `oidc_provider_url`: URL do OIDC Provider
- `node_group_arn`: ARN do node group
- `node_group_name`: Nome do node group

## 🔍 Troubleshooting

### Erro: "Reference to undeclared resource"
- **Causa**: Arquivos em subdiretórios não são lidos pelo Terraform
- **Solução**: Todos os recursos devem estar no diretório raiz do módulo

### Erro: "InvalidClientTokenId"
- **Causa**: Credenciais AWS não configuradas
- **Solução**: Execute `aws configure` ou configure variáveis de ambiente

### Erro: "Error loading state"
- **Causa**: State remoto não acessível ou não existe
- **Solução**: Verifique o bucket S3 e as permissões IAM

### Datadog não está coletando métricas
- Verifique se o parâmetro SSM `/datadog/api-key` existe
- Verifique os logs do pod Datadog: `kubectl logs -n datadog -l app=datadog`
- Verifique se o ExternalSecret foi criado: `kubectl get externalsecret -n datadog`

### ArgoCD não está acessível
- Obtenha a senha inicial: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- Faça port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- Acesse: `https://localhost:8080` (usuário: `admin`)

### External Secrets não está funcionando
- Verifique o SecretStore: `kubectl get secretstore -n datadog`
- Verifique o ExternalSecret: `kubectl get externalsecret -n datadog`
- Verifique os logs: `kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets`

## 🔐 Segurança

### Boas Práticas Implementadas

- ✅ **IRSA**: IAM Roles for Service Accounts para acesso seguro aos serviços AWS
- ✅ **External Secrets**: Secrets gerenciados via AWS SSM Parameter Store
- ✅ **Network Policies**: (Recomendado adicionar NetworkPolicies para isolamento)
- ✅ **RBAC**: Service Accounts com permissões mínimas necessárias
- ✅ **Endpoint Access**: Configuração de acesso público/privado ao cluster

## 💰 Otimização de Custos

### Configurações de Baixo Custo

- **Instâncias t3.medium**: Balance entre custo e performance
- **Node Group Fixo**: Sem auto-scaling para previsibilidade de custos
- **Resource Quotas**: Limites para evitar consumo excessivo
- **LimitRange**: Valores padrão conservadores para novos pods

### Estimativa de Custos (Região us-east-1)

- **EKS Cluster**: ~$0.10/hora (~$73/mês)
- **2x t3.medium**: ~$0.0832/hora cada (~$60/mês cada)
- **Total aproximado**: ~$193/mês (sem considerar tráfego e storage)

*Valores podem variar. Consulte a calculadora de preços da AWS.*

## 📚 Recursos Adicionais

- [Documentação EKS](https://docs.aws.amazon.com/eks/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Datadog Kubernetes](https://docs.datadoghq.com/agent/kubernetes/)
- [External Secrets Operator](https://external-secrets.io/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

## 📄 Licença

Este projeto é fornecido "como está" para fins educacionais e de demonstração.

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📧 Suporte

Para questões ou problemas, abra uma issue no repositório.

---

**Desenvolvido com ❤️ para otimização de infraestrutura Kubernetes na AWS**

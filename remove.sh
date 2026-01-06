#!/bin/bash
set -e

CLUSTER_NAME="nextime-cluster"
REGION="us-east-1"

echo "======================================"
echo "🔥 DESTRUINDO EKS COMPLETO"
echo "Cluster: $CLUSTER_NAME"
echo "Região:  $REGION"
echo "======================================"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "➡️ Atualizando kubeconfig (se existir)..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION || true

echo "➡️ Removendo Helm releases..."
helm uninstall argocd -n argocd || true
helm uninstall metrics-server -n kube-system || true
helm uninstall aws-load-balancer-controller -n kube-system || true
helm uninstall aws-ebs-csi-driver -n kube-system || true
helm uninstall external-secrets -n external-secrets || true

echo "➡️ Removendo namespaces..."
kubectl delete namespace argocd --wait=false || true
kubectl delete namespace external-secrets --wait=false || true
kubectl delete namespace datadog --wait=false || true

sleep 20

echo "➡️ Removendo CRDs External Secrets..."
kubectl delete crd \
  secretstores.external-secrets.io \
  clustersecretstores.external-secrets.io \
  externalsecrets.external-secrets.io || true

echo "======================================"
echo "🧨 DELETANDO NODE GROUPS"
echo "======================================"

NODEGROUPS=$(aws eks list-nodegroups \
  --cluster-name $CLUSTER_NAME \
  --region $REGION \
  --query "nodegroups[]" \
  --output text || true)

for NG in $NODEGROUPS; do
  echo "➡️ Deletando node group: $NG"
  aws eks delete-nodegroup \
    --cluster-name $CLUSTER_NAME \
    --nodegroup-name $NG \
    --region $REGION || true
done

echo "➡️ Aguardando node groups serem removidos..."
sleep 60

echo "======================================"
echo "🔥 DELETANDO CLUSTER EKS"
echo "======================================"

aws eks delete-cluster \
  --name $CLUSTER_NAME \
  --region $REGION || true

echo "➡️ Aguardando cluster ser removido..."
sleep 90

echo "======================================"
echo "🧹 LIMPANDO IAM (IRSA)"
echo "======================================"

aws iam detach-role-policy \
  --role-name external-secrets-role \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/external-secrets-ssm || true

aws iam detach-role-policy \
  --role-name aws-lb-controller-role \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/aws-load-balancer-controller || true

aws iam detach-role-policy \
  --role-name ebs-csi-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy || true

aws iam delete-role external-secrets-role || true
aws iam delete-role aws-lb-controller-role || true
aws iam delete-role ebs-csi-role || true

aws iam delete-policy \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/external-secrets-ssm || true

aws iam delete-policy \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/aws-load-balancer-controller || true

echo "======================================"
echo "✅ EKS COMPLETAMENTE REMOVIDO"
echo "Agora rode o Terraform do zero:"
echo ""
echo "terraform apply"
echo "======================================"

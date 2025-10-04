#!/bin/bash

echo "📎 Iniciando cluster Minikube..."
minikube start --cpus=4 --memory=8192

echo "📊 Habilitando metrics-server para HPA..."
minikube addons enable metrics-server

echo "🔧 Configurando kubectl para usar o contexto Minikube..."
kubectl config use-context minikube

echo "🚀 Aplicando recursos da aplicação..."
kubectl apply -f ./k8s --recursive

echo "✅ Deploy concluído!"
kubectl get hpa
kubectl get pods
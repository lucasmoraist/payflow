#!/bin/bash

# 'set -e' faz o script parar imediatamente se algum comando der erro.
# Isso evita que ele tente fazer deploy se o build falhar.
set -e

echo "Iniciando Minikube..."
minikube start --driver=docker

# --- NAVEGAÇÃO ---
# $(dirname "$0") pega o diretório onde o script está.
# /../../ sobe dois níveis.
cd "$(dirname "$0")/../../"

echo ""
echo "Diretorio de trabalho definido como raiz do projeto: $(pwd)"
echo ""

echo "Construindo infraestrutura de servicos..."
kubectl apply -f k8s/infrastructure.yml
echo "Infraestrutura de servicos aplicada."

echo ""
echo "----------------------------------------"
echo "Build and Deploy: Wallet-Core"
echo "----------------------------------------"
docker build -t payflow/wallet-core:latest ./wallet-core
minikube image load payflow/wallet-core:latest
echo "Servico Wallet-Core OK."

echo ""
echo "----------------------------------------"
echo "Build and Deploy: Transfer-Manager"
echo "----------------------------------------"
docker build -t payflow/transfer-manager:latest ./transfer-manager
minikube image load payflow/transfer-manager:latest
echo "Servico Transfer-Manager OK."

echo ""
echo "----------------------------------------"
echo "Build and Deploy: Notification-Svc"
echo "----------------------------------------"
docker build -t payflow/notification-svc:latest ./notification-svc
minikube image load payflow/notification-svc:latest
echo "Servico Notification-Svc OK."

echo ""
echo "Aplicando definicoes dos aplicativos..."
kubectl apply -f k8s/applications.yml

echo ""
echo "Iniciando o dashboard..."
minikube dashboard
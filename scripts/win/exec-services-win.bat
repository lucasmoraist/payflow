@echo off

echo Iniciando Minikube...
minikube start --driver=docker

cd /d "%~dp0..\..\"

echo.
echo Diretorio de trabalho definido como raiz do projeto: %cd%
echo.

echo Construindo infraestrutura de servicos...
kubectl apply -f k8s/infrastructure.yml
echo Infraestrutura de servicos aplicada.

echo.
echo ----------------------------------------
echo Build and Deploy: Wallet-Core
echo ----------------------------------------
:: Como ja estamos na raiz, apontamos para a pasta direto
docker build -t payflow/wallet-core:latest ./wallet-core
minikube image load payflow/wallet-core:latest
echo Servico Wallet-Core OK.

echo.
echo ----------------------------------------
echo Build and Deploy: Transfer-Manager
echo ----------------------------------------
docker build -t payflow/transfer-manager:latest ./transfer-manager
minikube image load payflow/transfer-manager:latest
echo Servico Transfer-Manager OK.

echo.
echo ----------------------------------------
echo Build and Deploy: Notification-Svc
echo ----------------------------------------
docker build -t payflow/notification-svc:latest ./notification-svc
minikube image load payflow/notification-svc:latest
echo Servico Notification-Svc OK.

echo.
echo Aplicando definicoes dos aplicativos...
kubectl apply -f k8s/applications.yml
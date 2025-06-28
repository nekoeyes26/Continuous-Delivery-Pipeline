@echo off
REM Menentukan profil production
set PROFILE=production
set CONTEXT=minikube-%PROFILE%

REM Ambil IP cluster production
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i

REM Ubah context kubectl agar mengarah ke production
kubectl config use-context %CONTEXT%

REM Ambil port service dari production
for /f "delims=" %%j in ('kubectl get svc calculator-service -o=jsonpath="{.spec.ports[0].nodePort}"') do set NODE_PORT=%%j

REM Cek endpoint /health
curl -s http://%NODE_IP%:%NODE_PORT%/health || exit /b 1
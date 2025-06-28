@echo off
REM Menentukan profil staging
set PROFILE=staging
set CONTEXT=minikube-%PROFILE%

REM Ambil IP cluster staging
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i

REM Ubah context kubectl agar mengarah ke staging
kubectl config use-context %CONTEXT%

REM Ambil port service dari staging
for /f "delims=" %%j in ('kubectl get svc calculator-service -o=jsonpath="{.spec.ports[0].nodePort}"') do set NODE_PORT=%%j

REM Jalankan acceptance test
gradlew.bat acceptanceTest -Dcalculator.url=http://%NODE_IP%:%NODE_PORT%
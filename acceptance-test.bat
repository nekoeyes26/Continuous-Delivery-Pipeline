@echo off
set PROFILE=staging
set CONTEXT=%PROFILE%

echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

echo Getting Minikube IP for profile: %PROFILE%...
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
echo NODE_IP=%NODE_IP%

echo Getting NodePort for calculator-service...
for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j
echo NODE_PORT=%NODE_PORT%

REM Validasi NODE_IP dan NODE_PORT
if "%NODE_IP%"=="" (
    echo ERROR: NODE_IP is empty!
    exit /b 1
)
if "%NODE_PORT%"=="" (
    echo ERROR: NODE_PORT is empty!
    exit /b 1
)

set CALCULATOR_URL=
for /f "delims=" %%u in ('minikube -p %PROFILE% service calculator-service --url 2^>nul') do set CALCULATOR_URL=%%u

if "%CALCULATOR_URL%"=="" (
    echo minikube --url failed, falling back to IP + NodePort
    for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
    for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j
    set CALCULATOR_URL=http://%NODE_IP%:%NODE_PORT%
)

echo Running acceptance test against %CALCULATOR_URL%
gradlew.bat acceptanceTest "-Dcalculator.url=%CALCULATOR_URL%"
@echo off
setlocal enabledelayedexpansion
set PROFILE=staging
set CONTEXT=%PROFILE%

:: Debug info
echo [DEBUG] Starting acceptance-test.bat

:: Switch kubectl context
echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

:: Get Minikube IP
echo Getting Minikube IP for profile: %PROFILE%...
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
echo NODE_IP=!NODE_IP!

:: Get NodePort
echo Getting NodePort for calculator-service...
for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j
echo NODE_PORT=!NODE_PORT!

:: Validate NODE_IP and NODE_PORT
if "!NODE_IP!"=="" (
    echo ERROR: NODE_IP is empty!
    exit /b 1
)
if "!NODE_PORT!"=="" (
    echo ERROR: NODE_PORT is empty!
    exit /b 1
)

:: Rakit URL langsung dari IP dan NodePort
set CALCULATOR_URL=http://!NODE_IP!:!NODE_PORT!

:: Debug CALCULATOR_URL
echo CALCULATOR_URL=!CALCULATOR_URL!

:: Extra check for special characters or empty value
if "!CALCULATOR_URL!"=="" (
    echo ERROR: CALCULATOR_URL is empty!
    exit /b 1
)

:: Run acceptance test
echo Running acceptance test against !CALCULATOR_URL!
call gradlew.bat acceptanceTest -Dcalculator.url=!CALCULATOR_URL!
endlocal
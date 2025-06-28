@echo off
setlocal EnableDelayedExpansion

set PROFILE=staging
set CONTEXT=%PROFILE%

echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

REM --- Get Minikube IP and NodePort ---
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j

if "!NODE_IP!"=="" (
    echo ERROR: NODE_IP is empty!
    exit /b 1
)
if "!NODE_PORT!"=="" (
    echo ERROR: NODE_PORT is empty!
    exit /b 1
)

set CALCULATOR_URL=http://!NODE_IP!:!NODE_PORT!
echo CALCULATOR_URL=!CALCULATOR_URL!

REM --- Tes HTTP dulu (opsional) ---
curl -s -o nul -w "%%{http_code}" "!CALCULATOR_URL!" > tmp_response.txt
set /p RESPONSE=<tmp_response.txt
echo HTTP response: !RESPONSE!

if NOT "!RESPONSE!"=="200" (
    echo ERROR: Service not responding
    exit /b 1
)

REM --- Jalankan gradle ---
echo Running acceptance test on !CALCULATOR_URL!
gradlew.bat acceptanceTest "-Dcalculator.url=!CALCULATOR_URL!"

endlocal

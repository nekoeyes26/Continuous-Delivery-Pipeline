@echo off
setlocal EnableDelayedExpansion

set PROFILE=staging
set CONTEXT=%PROFILE%

echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

REM --- Gunakan minikube service --url agar host bisa akses
set CALCULATOR_URL=
for /f "delims=" %%u in ('minikube -p %PROFILE% service calculator-service --url 2^>nul') do set CALCULATOR_URL=%%u

REM --- Fallback: jika gagal, gunakan IP + NodePort (jika tunnel gagal)
if "!CALCULATOR_URL!"=="" (
    echo minikube service --url failed, fallback ke IP + NodePort...

    for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
    for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j

    set CALCULATOR_URL=http://!NODE_IP!:!NODE_PORT!
)

echo CALCULATOR_URL=!CALCULATOR_URL!

REM --- Tes koneksi
curl -s -o nul -w "%%{http_code}" "!CALCULATOR_URL!" > tmp_response.txt
set /p RESPONSE=<tmp_response.txt
echo HTTP response: !RESPONSE!

if NOT "!RESPONSE!"=="200" (
    echo ERROR: Service not responding at !CALCULATOR_URL!
    exit /b 1
)

echo Running acceptance test on !CALCULATOR_URL!
gradlew.bat acceptanceTest "-Dcalculator.url=!CALCULATOR_URL!"

endlocal

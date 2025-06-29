@echo off
setlocal
set PROFILE=staging
set CONTEXT=%PROFILE%

echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

REM --- Coba ambil URL dari minikube --url ---
set CALCULATOR_URL=
for /f "delims=" %%u in ('minikube -p %PROFILE% service calculator-service --url 2^>nul') do set CALCULATOR_URL=%%u

if "%CALCULATOR_URL%"=="" (
    echo Fallback: Getting Minikube IP...
    for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
    echo NODE_IP=%NODE_IP%

    echo Fallback: Getting NodePort...
    for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j
    echo NODE_PORT=%NODE_PORT%

    if "%NODE_IP%"=="" (
        echo ERROR: NODE_IP is empty!
        exit /b 1
    )
    if "%NODE_PORT%"=="" (
        echo ERROR: NODE_PORT is empty!
        exit /b 1
    )

    set CALCULATOR_URL=http://%NODE_IP%:%NODE_PORT%
)

echo Final CALCULATOR_URL="%CALCULATOR_URL%"

REM --- Jalankan acceptance Test hanya jika CALCULATOR_URL valid ---
if "%CALCULATOR_URL%"=="" (
    echo ERROR: CALCULATOR_URL is empty!
    exit /b 1
)

REM --- Test koneksi (opsional) ---
REM Gunakan curl -I untuk mendapatkan status code di Windows
curl -s -I "%CALCULATOR_URL%" > tmp_response.txt
set RESPONSE=
for /f "tokens=2 delims= " %%a in ('findstr /i "HTTP/" tmp_response.txt') do set RESPONSE=%%a

echo HTTP response: %RESPONSE%
if NOT "%RESPONSE%"=="200" (
    echo ERROR: Service not responding
    exit /b 1
)

REM --- Jalankan acceptance test ---
echo Running acceptance test on "%CALCULATOR_URL%"
gradlew.bat acceptanceTest "-Dcalculator.url=%CALCULATOR_URL%"

endlocal

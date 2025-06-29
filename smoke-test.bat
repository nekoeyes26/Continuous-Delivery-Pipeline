@echo off
setlocal enabledelayedexpansion
set PROFILE=production
set CONTEXT=%PROFILE%

:: Debug info
echo [DEBUG] Starting smoke-test.bat

echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

echo Getting Minikube IP for profile: %PROFILE%...
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
echo NODE_IP=!NODE_IP!

echo Getting NodePort for calculator-service...
for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j
echo NODE_PORT=!NODE_PORT!

if "!NODE_IP!"=="" (
    echo ERROR: NODE_IP is empty!
    exit /b 1
)
if "!NODE_PORT!"=="" (
    echo ERROR: NODE_PORT is empty!
    exit /b 1
)

:: Port forwarding ke 4445
start /min cmd /c "kubectl port-forward svc/calculator-service 4445:8080 > portforward.log 2>&1"

:: Tunggu port forwarding siap (maks 20 detik)
set /a COUNT=0
:wait_port
powershell -Command "try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('localhost',4445); $c.Close(); exit 0 } catch { exit 1 }"
if not errorlevel 1 goto port_ready
set /a COUNT+=1
if %COUNT% GEQ 20 (
    echo ERROR: Port forwarding ke 4445 gagal!
    exit /b 1
)
timeout /t 1 >nul
goto wait_port
:port_ready

set CALCULATOR_URL=http://localhost:4445

echo CALCULATOR_URL=!CALCULATOR_URL!

if "!CALCULATOR_URL!"=="" (
    echo ERROR: CALCULATOR_URL is empty!
    exit /b 1
)

echo Running smoke test against !CALCULATOR_URL!
curl -s !CALCULATOR_URL!/health || exit /b 1
endlocal
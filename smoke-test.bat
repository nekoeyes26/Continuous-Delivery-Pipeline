@echo off
REM Menentukan profil production
set PROFILE=production
set CONTEXT=%PROFILE%

REM Ambil IP cluster production
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i

REM Ubah context kubectl agar mengarah ke production
kubectl config use-context %CONTEXT%

REM Ambil port service dari production
for /f "delims=" %%j in ('kubectl get svc calculator-service -o "jsonpath={.spec.ports[0].nodePort}"') do set NODE_PORT=%%j

REM Port forwarding ke 4445
start /min cmd /c "kubectl port-forward svc/calculator-service 4445:8080 > portforward.log 2>&1"

REM Tunggu port forwarding siap (maks 20 detik)
set /a COUNT=0
:wait_port
curl -s http://localhost:4445/health >nul 2>&1
if not errorlevel 1 goto port_ready
set /a COUNT+=1
if %COUNT% GEQ 20 (
    echo ERROR: Port forwarding ke 4445 gagal!
    exit /b 1
)
timeout /t 1 >nul
goto wait_port
:port_ready

REM Cek endpoint /health
curl -s http://localhost:4445/health || exit /b 1
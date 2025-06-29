@echo off
setlocal enabledelayedexpansion
set PROFILE=production
set CONTEXT=%PROFILE%

echo [DEBUG] Starting smoke-test.bat

echo Switching kubectl context to %CONTEXT%...
kubectl config use-context %CONTEXT%

:: Kill any process using port 4444 (cleanup acceptance test)
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :4444') do taskkill /F /PID %%p >nul 2>&1
:: Kill any process using port 4445 (cleanup smoke test)
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :4445') do taskkill /F /PID %%p >nul 2>&1

echo Starting port-forward to 4445...
start /min "" cmd /c "kubectl port-forward svc/calculator-service 4445:8080 > portforward.log 2>&1"

:: Tunggu port forwarding siap (maks 20 detik)
set /a COUNT=0
:wait_port
curl -s http://localhost:4445/health >nul 2>&1
if not errorlevel 1 goto port_ready
set /a COUNT+=1
if %COUNT% GEQ 20 (
    echo ERROR: Port forwarding ke 4445 gagal!
    echo --- portforward.log ---
    type portforward.log
    exit /b 1
)
timeout /t 1 >nul
goto wait_port
:port_ready

echo Port forwarding ke 4445 berhasil.
set CALCULATOR_URL=http://localhost:4445

echo CALCULATOR_URL=!CALCULATOR_URL!

if "!CALCULATOR_URL!"=="" (
    echo ERROR: CALCULATOR_URL is empty!
    exit /b 1
)

echo Running smoke test against !CALCULATOR_URL!
call gradlew.bat smokeTest -Dcalculator.url=!CALCULATOR_URL!
endlocal
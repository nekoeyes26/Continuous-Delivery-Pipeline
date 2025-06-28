@echo off
set PROFILE=staging
for /f "delims=" %%i in ('minikube -p %PROFILE% ip') do set NODE_IP=%%i
for /f "delims=" %%j in ('kubectl get svc calculator-service -o=jsonpath="{.spec.ports[0].nodePort}"') do set NODE_PORT=%%j
gradlew.bat acceptanceTest -Dcalculator.url=http://%NODE_IP%:%NODE_PORT%

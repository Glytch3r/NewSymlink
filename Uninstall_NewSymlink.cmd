@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell -Command "Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\\Directory\\Background\\shell\\NewSymlink' -Recurse -Force"
echo [SUCCESS] 'New Symlink' has been removed.
pause

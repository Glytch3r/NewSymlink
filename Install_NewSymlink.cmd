:: Elevate script if not admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

@echo off
setlocal

set KEY_NAME=HKCR\Directory\Background\shell\NewSymlink
set SCRIPT_PATH=%~dp0NewSymlink.ps1

:: Remove old entry
reg delete "%KEY_NAME%" /f >nul 2>&1

:: Add context menu entry
reg add "%KEY_NAME%" /ve /d "New Symlink" /f
reg add "%KEY_NAME%" /v "Icon" /d "shell32.dll,3" /f
reg add "%KEY_NAME%" /v "Position" /d "Top" /f

:: Directly run PowerShell script (self-elevation handled in script)
reg add "%KEY_NAME%\command" /ve /d "powershell -NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_PATH%\" \"%%V\"" /f

echo.
echo [SUCCESS] 'New Symlink' has been added to the context menu.
pause

:: Generate uninstaller
(
echo @echo off
echo net session ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 ^(
echo     powershell -Command "Start-Process '%%~f0' -Verb RunAs"
echo     exit /b
echo ^)
echo powershell -Command "Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\\Directory\\Background\\shell\\NewSymlink' -Recurse -Force"
echo echo [SUCCESS] 'New Symlink' has been removed.
echo pause
) > "%~dp0Uninstall_NewSymlink.cmd"

endlocal
exit /b

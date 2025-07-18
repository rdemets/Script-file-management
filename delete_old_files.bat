@echo off

REM Set the number of days before deleting the file
set "DAYS_OLD=120"
set "TARGET_DIR=D:\archive"

:: Set the log file path based on the current date (yyyy-MM-dd format)
setlocal enabledelayedexpansion
for /f "tokens=2 delims==" %%D in ('"wmic os get LocalDateTime /value"') do set DATETIME=%%D
set "LOG_FILE=D:\logs\delete_log_%datetime:~0,8%.txt"

if not exist "D:\logs" mkdir "D:\logs"





:: Add a timestamp to the log
echo Log started at %DATE% %TIME% >> "%LOG_FILE%"

:: Display Windows Toast Notification (asynchronous)
:: start "" powershell -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Running Data Deletion. Do not disturb')"

:: Print the list of files older than X days from TARGET
echo Checking files older than %DAYS_OLD% days in %TARGET_DIR%
pushd %TARGET_DIR%

:: Iterate over files older than X days, log their paths, and delete them
forfiles /S /M *.* /D -%DAYS_OLD% /C "cmd /C if @isdir==FALSE (echo Deleting: @path >> %LOG_FILE%)"
forfiles /S /M *.* /D -%DAYS_OLD% /C "cmd /C if @isdir==FALSE (del @path)"



REM Delete empty directories
echo Deleting empty directories from %TARGET_DIR%...


REM Loop through all directories in reverse order (to ensure parent directories get checked after children)
for /f "delims=" %%D in ('dir "%TARGET_DIR%" /ad /s /b') do (
    rmdir "%%D" >nul 2>&1
)



:: Add a timestamp to the log
echo Task completed at %DATE% %TIME% >> "%LOG_FILE%"

popd

:: Display Windows Toast Notification (asynchronous)
:: start "" powershell -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Task completed! Log saved to %LOG_FILE%')"

:: Add a pause to prevent the window from closing immediately
pause

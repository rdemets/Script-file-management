@echo off
setlocal enabledelayedexpansion

REM Set the number of days before moving the file
set "DAYS_OLD=60"

set "SOURCE_DIR=E:"
set "TARGET_DIR=D:\archive\"

REM Create log file named after the current date and time
for /f "tokens=2 delims==" %%D in ('"wmic os get LocalDateTime /value"') do set DATETIME=%%D
set "LOG_FILE=D:\logs\move_log_%datetime:~0,8%.txt"


REM Ensure the logs directory exists
if not exist "D:\logs" mkdir "D:\logs"




REM Check if source directory exists
if not exist "%SOURCE_DIR%" (
    echo Source directory %SOURCE_DIR% does not exist.
    exit /b 1
)

REM Check if target directory exists, create it if necessary
if not exist "%TARGET_DIR%" (
    echo Target directory %TARGET_DIR% does not exist. Creating it...
    mkdir "%TARGET_DIR%"
)

echo Task started at %DATE% %TIME% >> "%LOG_FILE%"
echo Searching for files older than %DAYS_OLD% days in %SOURCE_DIR%...
echo Searching for files older than %DAYS_OLD% days in %SOURCE_DIR%... >> "%LOG_FILE%"

REM Use PowerShell to find files older than 14 days
for /f "delims=" %%F in ('powershell -NoProfile -Command ^
    "Get-ChildItem -Path '%SOURCE_DIR%' -Recurse -Filter '*.*' | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-%DAYS_OLD%))} | Select-Object -ExpandProperty FullName"') do (

    REM Calculate the relative path
    set "RELATIVE_PATH=%%F"
    set "RELATIVE_PATH=!RELATIVE_PATH:%SOURCE_DIR%=!"

    REM Calculate the target path
    set "TARGET_PATH=%TARGET_DIR%!RELATIVE_PATH!"

    REM Normalize backslashes (remove double backslashes)
    set "TARGET_PATH=!TARGET_PATH:\\=\!"

    REM Ensure the target directory exists
    for %%D in ("!TARGET_PATH!") do mkdir "%%~dpD" >nul 2>&1

    REM Move the file
    echo Moving: %%F to !TARGET_PATH!
    echo Moving: %%F to !TARGET_PATH! >> "%LOG_FILE%"
    move "%%F" "!TARGET_PATH!" >nul 2>&1

    REM Check if the move was successful
    if errorlevel 1 (
        echo Failed to move: %%F
    )
)


REM Delete empty directories
echo Deleting empty directories from %SOURCE_DIR%...


REM Loop through all directories in reverse order (to ensure parent directories get checked after children)
for /f "delims=" %%D in ('dir "%SOURCE_DIR%" /ad /s /b') do (
    rmdir "%%D" >nul 2>&1
)


echo Task completed at %DATE% %TIME% >> "%LOG_FILE%"




:: Add a pause to prevent the window from closing immediately
:: pause

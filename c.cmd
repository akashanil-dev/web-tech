@echo off
setlocal EnableDelayedExpansion

set "URL=http://129.159.228.210:8000"
set "USERNAME=the_user"
set "PASSWORD=jj7*7hggfFHghjtGJh%%GhfgfjyFJH%%456"

cls
echo.
echo Connecting to Oracle server.

:: 1. Login
echo {"username":"%USERNAME%","password":"%PASSWORD%"} > "%TEMP%\ai_login.json"
curl -s -X POST -H "Content-Type: application/json" -d @"%TEMP%\ai_login.json" "%URL%/login" > "%TEMP%\ai_login_res.json"

set "TOKEN="
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-Content '%TEMP%\ai_login_res.json' | ConvertFrom-Json).access_token" 2^>nul`) do set "TOKEN=%%A"

if "%TOKEN%"=="" (
    echo ORA-12154: TNS:could not resolve the connect identifier specified ^(Login failed!^)
    goto :eof
)


set /a LINENUM=1
type nul > "%TEMP%\ai_req.txt"

:input_loop
if !LINENUM! EQU 1 (
    set "PROMPT_TEXT=SQL> "
) else (
    if !LINENUM! LSS 10 (
        set "PROMPT_TEXT=  !LINENUM!  "
    ) else if !LINENUM! LSS 100 (
        set "PROMPT_TEXT= !LINENUM!  "
    ) else (
        set "PROMPT_TEXT=!LINENUM!  "
    )
)

set "USERINPUT="
set /p "USERINPUT=!PROMPT_TEXT!"

:: Check for EXIT
if "!LINENUM!"=="1" if /I "!USERINPUT!"=="EXIT" (
    echo Disconnected from Oracle Database
    goto :eof
)

:: Check for CLEAR
if "!LINENUM!"=="1" if /I "!USERINPUT!"=="CLEAR" (
    curl -s -X POST -H "Authorization: Bearer %TOKEN%" "%URL%/clear" > nul
    if exist "%TEMP%\src.json" del "%TEMP%\src.json"
    echo.
    echo System altered. ^(History Cleared^)
    echo.
    goto :input_loop
)

:: Check for Execute '/'
if "!USERINPUT!"=="/" (
    if "!LINENUM!"=="1" (
        goto :input_loop
    )
    
    echo.
    echo Executing...
    
    :: Convert to JSON and send to chat API, extract reply to ai_res.txt
    powershell -NoProfile -Command "$hf = '%TEMP%\src.json'; $b = ''; if (Test-Path '%TEMP%\ai_req.txt') { $b = (Get-Content '%TEMP%\ai_req.txt' -Raw).Trim() }; $h = @(); if(Test-Path $hf){$h = @(Get-Content $hf -Raw | ConvertFrom-Json)}; $h += $b; if($h.Count -gt 10){$h = $h[($h.Count - 10)..($h.Count - 1)]}; $h | ConvertTo-Json -Compress | Set-Content $hf; $nl = [Environment]::NewLine; $ctx = ''; if($h.Count -gt 1){ $ctx = 'Past queries:' + $nl + ($h[0..($h.Count-2)] -join ($nl + '---' + $nl)) + $nl + $nl }; $sys = 'Act strictly as an Oracle PL/SQL and MySQL database engine. Output ONLY the raw code, query results, or direct technical answer. NEVER use greetings, pleasantries, or conversational filler.' + $nl + $ctx + 'Current User input:' + $nl + $b; $body = @{message = $sys} | ConvertTo-Json -Depth 10; try { (Invoke-RestMethod -Method Post -Uri '%URL%/chat' -Headers @{Authorization = 'Bearer %TOKEN%'} -ContentType 'application/json' -Body $body).reply } catch { 'ORA-03113: end-of-file on communication channel' }" > "%TEMP%\ai_res.txt"
    
    echo.
    type "%TEMP%\ai_res.txt"
    echo.
    
    :: Reset buffer
    type nul > "%TEMP%\ai_req.txt"
    set /a LINENUM=1
    goto :input_loop
)

:: Append input to req.txt file
echo !USERINPUT!>> "%TEMP%\ai_req.txt"
set /a LINENUM+=1

goto :input_loop

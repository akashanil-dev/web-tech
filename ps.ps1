$ErrorActionPreference = 'Stop'
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$URL = "http://129.159.228.210:8000"
$Username = "the_user"
$Password = "jj7*7hggfFHghjtGJh%GhfgfjyFJH%456"

Clear-Host
Write-Host "SQL*Plus: Release 2026.0 - Production on $($ (Get-Date).ToString('ddd N MMM d HH:mm:ss yyyy'))" -ForegroundColor Cyan
Write-Host "Copyright (c) 1982, 2026, Oracle AI.  All rights reserved.`n" -ForegroundColor Cyan
Write-Host "Connecting to Oracle AI server..." -ForegroundColor DarkGray

# 1. Login to get Token
$LoginBody = @{ username = $Username; password = $Password } | ConvertTo-Json
try {
    $LoginResponse = Invoke-RestMethod -Method Post -Uri "$URL/login" -ContentType "application/json" -Body $LoginBody
    $Token = $LoginResponse.access_token
} catch {
    Write-Host "ORA-12154: TNS:could not resolve the connect identifier specified (Login failed!)" -ForegroundColor Red
    exit
}

Write-Host "Connected to:" -ForegroundColor Green
Write-Host "Oracle AI Database 21c Enterprise Edition Release 21.0.0.0.0 - Production" -ForegroundColor Green
Write-Host "Version 21.3.0.0.0`n" -ForegroundColor Green

Write-Host "=====================================================================" -ForegroundColor Yellow
Write-Host "                  PL/SQL & MySQL AI Assistant Mode" -ForegroundColor White
Write-Host "=====================================================================" -ForegroundColor Yellow
Write-Host " -> Paste your multi-line code directly into the terminal." -ForegroundColor Gray
Write-Host " -> End your message by typing a single slash '/' on a new line and pressing Enter." -ForegroundColor Gray
Write-Host " -> Type CLEAR to reset history, EXIT to quit.`n" -ForegroundColor Gray

$buffer = ""
$lineNum = 1

while ($true) {
    if ($lineNum -eq 1) {
        $prompt = "SQL> "
    } else {
        $prompt = "{0,3}  " -f $lineNum
    }

    # Read input from the user
    $userInput = Read-Host $prompt
    
    if ($lineNum -eq 1 -and $userInput.Trim().ToUpper() -eq "EXIT") { 
        Write-Host "Disconnected from Oracle AI Database" -ForegroundColor DarkGray
        break 
    }

    if ($lineNum -eq 1 -and $userInput.Trim().ToUpper() -eq "CLEAR") {
        try {
            Invoke-RestMethod -Method Post -Uri "$URL/clear" -Headers @{ Authorization = "Bearer $Token" } | Out-Null
            Write-Host "`nSystem altered. (History Cleared)`n" -ForegroundColor Yellow
        } catch {
            Write-Host "`nORA-00000: Failed to clear history.`n" -ForegroundColor Red
        }
        continue
    }

    # If the user enters a single slash, submit the query
    if ($userInput.Trim() -eq "/") {
        if ([string]::IsNullOrWhiteSpace($buffer)) {
            $buffer = ""
            $lineNum = 1
            continue
        }

        Write-Host "`nExecuting..." -ForegroundColor DarkGray
        
        $ChatBody = @{ message = $buffer.Trim() } | ConvertTo-Json -Depth 10

        try {
            $ChatResponse = Invoke-RestMethod -Method Post -Uri "$URL/chat" -Headers @{ Authorization = "Bearer $Token" } -ContentType "application/json" -Body $ChatBody
            
            # Print response in a copy-pastable format
            Write-Host "`n================================================================================" -ForegroundColor Cyan
            Write-Host $ChatResponse.reply -ForegroundColor White
            Write-Host "================================================================================`n" -ForegroundColor Cyan
        } catch {
            Write-Host "`nORA-03113: end-of-file on communication channel (Error connecting to AI server)`n" -ForegroundColor Red
        }
        
        # Reset buffer for next query
        $buffer = ""
        $lineNum = 1
    } else {
        # Append to buffer
        if ($lineNum -eq 1) {
            $buffer = $userInput
        } else {
            $buffer += "`n" + $userInput
        }
        $lineNum++
    }
}

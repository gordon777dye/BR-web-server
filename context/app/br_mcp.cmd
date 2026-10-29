@echo off
rem MCP entry for Claude Code (.mcp.json): makes sure a BR harness session is being
rem served, then relays stdin/stdout to it with "br_mcp_driver connect".
rem
rem If the driver's pipe is not there, this starts "br_mcp_driver start" detached and
rem hidden (BR itself shows its own window) with the GUI ON AI config, logs its lines to
rem context\app\br_mcp_start.log, and waits up to 60 seconds for the pipe. Nothing but
rem connect may write to stdout here: stdout is the MCP channel.

cd /d "%~dp0..\.."
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$pipe = 'br_mcp_driver.' + $env:USERNAME + '.requests';" ^
  "function Up { [IO.Directory]::GetFiles('\\.\pipe\') | Where-Object { $_ -like ('*' + $pipe) } }" ^
  "if (Up) { exit 0 }" ^
  "Start-Process cmd.exe -WindowStyle Hidden -WorkingDirectory (Get-Location).Path -ArgumentList '/c context\app\env.cmd && context\dev\ai_access\br_mcp_driver.exe start --config context\dev\tools\brconfig.ai_gui > context\app\br_mcp_start.log 2>&1';" ^
  "for ($i = 0; $i -lt 120; $i++) { if (Up) { exit 0 }; Start-Sleep -Milliseconds 500 }" ^
  "exit 1" >nul 2>&1
if errorlevel 1 (
   echo br_mcp.cmd: the BR harness service did not come up; see context\app\br_mcp_start.log 1>&2
   exit /b 1
)
"%~dp0..\dev\ai_access\br_mcp_driver.exe" connect

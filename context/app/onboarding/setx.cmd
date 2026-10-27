@echo off
rem Saves the BR launch environment variables in the Windows user profile, so
rem every program started afterwards has them. Generated and run by
rem ONBOARDING.md STEP 1. Takes its values from ..\env.cmd, so the two never
rem disagree. Re-run it if the kit moves.
rem
rem The values reach only programs started after this runs: close every VS Code
rem window and start it again. To remove one: reg delete HKCU\Environment /v <NAME> /f

setlocal
call "%~dp0..\env.cmd"

setx BR_CONTEXT_KIT "%BR_CONTEXT_KIT%" >nul || goto failed
setx APP_ROOT       "%APP_ROOT%"       >nul || goto failed
setx BR_EXE         "%BR_EXE%"         >nul || goto failed
setx BR_MCP_DRIVER  "%BR_MCP_DRIVER%"  >nul || goto failed
setx BR_CONFIG      "%BR_CONFIG%"      >nul || goto failed
setx BR_AI_UTIL     "%BR_AI_UTIL%"     >nul || goto failed
setx BR_AI_USER     "%BR_AI_USER%"     >nul || goto failed
setx BRLS_EXE       "%BRLS_EXE%"       >nul || goto failed

set APP_ROOT
set BR
exit /b 0

:failed
echo setx failed; nothing after the first failure was saved.
exit /b 1

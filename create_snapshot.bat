@ECHO OFF
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass . '%~dp0run_remote_script.ps1' -scriptName 'CreateSnapshot' %*
ECHO ERRORLEVEL: %ERRORLEVEL%
EXIT /B
@ECHO OFF
IF "%SSHSESSIONID%" NEQ "" CHCP 65001
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass . '%~dp0run_snaphot_operation.ps1' -scriptName 'CreateSnapshot' %*
ECHO ERRORLEVEL: %ERRORLEVEL%
EXIT /B
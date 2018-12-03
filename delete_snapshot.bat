@ECHO OFF
IF "%SSHSESSIONID%" NEQ "" CHCP 65001
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass . '%~dp0run_remote_script.ps1' -scriptName 'DeleteSnapshot' %*
ECHO ERRORLEVEL: %ERRORLEVEL%
EXIT /B
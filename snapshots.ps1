[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

Add-Type -Debug:$FALSE -Language "CSharp" -TypeDefinition '
  using System;
  using System.Runtime.InteropServices;

  namespace mklink
  {
    public class symlink
    {
      [DllImport("kernel32.dll")]
      public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags);
    }
  }
'

$script:oemEncoding = [System.Text.Encoding]::GetEncoding($Host.CurrentCulture.TextInfo.OEMCodePage)
$script:ansiEncoding = [System.Text.Encoding]::GetEncoding($Host.CurrentCulture.TextInfo.ANSICodePage)

function RunConsoleCommand {
param(
  [string]$command,
  [string[]]$parameters
)
  & $command $parameters | ForEach-Object { $script:oemEncoding.GetString($script:ansiEncoding.GetBytes($_)) }
}

function CheckAdministratorPrivileges {
param()
  if (-not(
    New-Object -TypeName "Security.Principal.WindowsPrincipal" -ArgumentList ([Security.Principal.WindowsIdentity]::GetCurrent())
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    { throw "This script must be run with elevated user rights (as Administrator)" }
}

function GetBackupObjects {
param()
  $filePath = Join-Path -Path ${Env:ProgramData} -ChildPath "backuppc\backup_objects.xml"
  $objectsXML = New-Object System.Xml.XmlDocument
  if (Test-Path -Path $filePath) {
    $objectsXML.Load($filePath)
  } else {
    $objectsXML.AppendChild($objectsXML.CreateElement("backuppc")) | Out-Null
  } #if
  return $objectsXML.DocumentElement
}

function SaveBackupObjects {
param(
  [System.Xml.XmlElement]$backupObjects
)
  $programDataPath = Join-Path -Path ${Env:ProgramData} -ChildPath "backuppc"
  New-Item -ItemType "Directory" -Path $programDataPath -Force | Out-Null 
  $backupObjects.OwnerDocument.Save($programDataPath + "\backup_objects.xml")
}


function CreateShadowCopy {
[CmdletBinding()]
param(
  [string]$drive
)
  Write-Host ("Creating shadow copy for drive {0}:" -f $drive)

  $shadowCopyID = ((Get-WmiObject -List Win32_ShadowCopy).Create($drive + ":\", "ClientAccessible").ShadowID)
  $shadowCopy = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.ID -eq $shadowCopyID }
  Write-Host ("Shadow copy ID: {0} ({1})" -f $shadowCopyID, $shadowCopy.DeviceObject)

  $backupObjects = GetBackupObjects
  $backupObjects.AppendChild($backupObjects.OwnerDocument.CreateElement("shadow_copy")).InnerText = $shadowCopyID
  SaveBackupObjects -backupObjects $backupObjects

  # Make sure trailing backslash is present or directory listing will fail
  return ($shadowCopy.DeviceObject + '\')
}

function CreateLink{
param(
  [string]$shadowCopyDevice,
  [string]$drive
)
  $symlinkPath = Join-Path -Path ${Env:ProgramData} -ChildPath "backuppc\mnt"
  New-Item -ItemType "Directory" -Path $symlinkPath -Force | Out-Null 
  $symlinkPath = Join-Path -Path $symlinkPath -ChildPath ("drive_" + $drive)
  Write-Host ("Creating link {0} ==> {1}" -f $symlinkPath, $shadowCopyDevice)
  # dwFlags: SYMBOLIC_LINK_FLAG_DIRECTORY=0x1
  if (-not([mklink.symlink]::CreateSymbolicLink($symlinkPath, $shadowCopyDevice, 1)))
    { throw ("Failed to create link {0} ==> {1}" -f $symlinkPath, $shadowCopyDevice) }

  $backupObjects = GetBackupObjects
  $backupObjects.AppendChild($backupObjects.OwnerDocument.CreateElement("symlink")).InnerText = $symlinkPath
  SaveBackupObjects -backupObjects $backupObjects

  return $symlinkPath
}

function CreateNetworkShare{
param(
  [string]$shareName,
  [string]$sharePath,
  [string]$grantAccessTo
)
  Write-Host ("Sharing '{0}' as '{1}' with read access for '{2}'" -f $sharePath, $shareName, $grantAccessTo)
  # net share "backup_C=c:\ProgramData\backuppc\mnt\drive_C" /grant:"group-or-user,READ"
  RunConsoleCommand -command "net" -parameters @("share", ("{0}={1}" -f $shareName, $sharePath), ('/grant:"{0},READ"' -f $grantAccessTo))

  $backupObjects = GetBackupObjects
  $backupObjects.AppendChild($backupObjects.OwnerDocument.CreateElement("share")).InnerText = $shareName
  SaveBackupObjects -backupObjects $backupObjects
}


function DeactivateBackupObjects {
[CmdletBinding()]
param()
  $backupObjects = GetBackupObjects

  foreach ($share in $backupObjects.SelectNodes("share")) {
    # Write-Host ("\\localhost\" + $share.InnerText) -Fore Cyan
    # Write-Host (Test-Path -Path ("\\localhost\" + $share.InnerText)) -Fore Cyan
    $shareExists = $FALSE
    foreach ($line in (& "net" @("share"))) {
      if ($line.split()[0] -eq $share.InnerText) {
        $shareExists = $TRUE
        break
      } #if
    } #foreach

    if ($shareExists) {
      Write-Host ("Deleting network share '{0}'" -f $share.InnerText)
      # /Y option is not documented but seems to force share deletion in case
      # users have open files on it
      RunConsoleCommand -command "net" -parameters @("share", $share.InnerText, "/DELETE", "/Y")
    } #if
    $share.ParentNode.RemoveChild($share) | Out-Null
    SaveBackupObjects -backupObjects $backupObjects
  } #foreach

  foreach ($symlink in $backupObjects.SelectNodes("symlink")) {
    if (Test-Path -Path $symlink.InnerText) {
      Write-Host ("Deleting symlink '{0}'" -f $symlink.InnerText)
      # Recursive: false
      [System.IO.Directory]::Delete($symlink.InnerText, $FALSE)
    } #if
    $symlink.ParentNode.RemoveChild($symlink) | Out-Null
    SaveBackupObjects -backupObjects $backupObjects
  } #foreach

  foreach ($shadowCopy in $backupObjects.SelectNodes("shadow_copy")) {
    $shadowObj = (Get-WmiObject Win32_ShadowFor) |
      Where-Object { $_.Dependent -match $shadowCopy.InnerText }
    if ($shadowObj) {
      # If shadow copy still exists, delete it
      $deviceID = $shadowObj.Antecedent
      # Antecedent property returns value like this:
      # Win32_Volume.DeviceID="\\\\?\\Volume{00000000-0000-0000-0000-000000000000}\\"
      # We parse it to get only the following part:
      # \\?\Volume{00000000-0000-0000-0000-000000000000}\
      $deviceID = $deviceID.Split("=")[1].Split('"')[1].Replace("\\", "\")
      # Now we can look up the drive letter
      $driveLetter = (Get-WmiObject -Class Win32_Volume | Where-Object {$_.DeviceID -eq $deviceID }).DriveLetter
      Write-Host ("Deleting shadow copy {0} (drive {1})" -f $shadowCopy.InnerText, $driveLetter)
      (Get-WmiObject Win32_ShadowCopy | Where-Object { $_.ID -eq $shadowCopy.InnerText }).Delete()
    } else {
      Write-Host ("[!] WARNING: Shadow copy {0} has already been deleted" -f $shadowCopy.InnerText)
    } #if
    $shadowCopy.ParentNode.RemoveChild($shadowCopy) | Out-Null
    SaveBackupObjects -backupObjects $backupObjects
  } #foreach
}

function CreateSnapshot {
[CmdletBinding()]
param(
  [hashtable]$parameters
)
  # TODO: Check parameters
  # Write-Host ($parameters | Out-String) -Fore Cyan

  CheckAdministratorPrivileges

  Write-Host "Checking for existing backup objects..."
  DeactivateBackupObjects

  if (-not($parameters["drives"]))
    { throw "'drives' parameter is not specified" }
  foreach ($drive in $parameters["drives"]) {
    # Make sure it's drive letter only (not "C:" or "C:\")
    $drive = $drive.substring(0, 1).toupper()
    $shadowCopyDevice = CreateShadowCopy -drive $drive
    $sharePath = CreateLink -shadowCopyDevice $shadowCopyDevice -drive $drive
    CreateNetworkShare -shareName ("backup_" + $drive) -sharePath $sharePath -grantAccessTo $parameters["share_user"]
  } #foreach
}

function DeleteSnapshot {
[CmdletBinding()]
param(
  [hashtable]$parameters
)
  CheckAdministratorPrivileges

  Write-Host "Removing all backup objects..."
  DeactivateBackupObjects
}
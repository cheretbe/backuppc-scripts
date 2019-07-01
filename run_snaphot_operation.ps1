[CmdletBinding()]
param(
  [string]$scriptName,
  [string]$hostName,
  [string]$userName,
  [string]$password,
  [switch]$useSSL,
  [hashtable]$parameters
)

Set-StrictMode -Version Latest
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$Host.PrivateData.VerboseForegroundColor = [ConsoleColor]::DarkCyan

$script:scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:snapshotsScriptPath = (Join-Path -Path $script:scriptDir -ChildPath "snapshots.ps1")

# https://gallery.technet.microsoft.com/scriptcenter/Send-Files-or-Folders-over-273971bf
# Updated: 8/19/2015
# PS 2.0 Fix: Mandatory=$TRUE
function Send-File {
  <#
  .SYNOPSIS
    This function sends a file (or folder of files recursively) to a destination WinRm session. This function was originally
    built by Lee Holmes (http://poshcode.org/2216) but has been modified to recursively send folders of files as well
    as to support UNC paths.

  .PARAMETER Path
    The local or UNC folder path that you'd like to copy to the session. This also support multiple paths in a comma-delimited format.
    If this is a UNC path, it will be copied locally to accomodate copying.  If it's a folder, it will recursively copy
    all files and folders to the destination.

  .PARAMETER Destination
    The local path on the remote computer where you'd like to copy the folder or file.  If the folder does not exist on the remote
    computer it will be created.

  .PARAMETER Session
    The remote session. Create with New-PSSession.

  .EXAMPLE
    $session = New-PSSession -ComputerName MYSERVER
    Send-File -Path C:\test.txt -Destination C:\ -Session $session

    This example will copy the file C:\test.txt to be C:\test.txt on the computer MYSERVER

  .INPUTS
    None. This function does not accept pipeline input.

  .OUTPUTS
    System.IO.FileInfo
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Path,
    
    [Parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [string]$Destination,
    
    [Parameter(Mandatory=$TRUE)]
    [System.Management.Automation.Runspaces.PSSession]$Session
  )
  process
  {
    foreach ($p in $Path)
    {
      try
      {
        if ($p.StartsWith('\\'))
        {
          Write-Verbose -Message "[$($p)] is a UNC path. Copying locally first"
          Copy-Item -Path $p -Destination ([environment]::GetEnvironmentVariable('TEMP', 'Machine'))
          $p = "$([environment]::GetEnvironmentVariable('TEMP', 'Machine'))\$($p | Split-Path -Leaf)"
        }
        if (Test-Path -Path $p -PathType Container)
        {
          Write-Log -Source $MyInvocation.MyCommand -Message "[$($p)] is a folder. Sending all files"
          $files = Get-ChildItem -Path $p -File -Recurse
          $sendFileParamColl = @()
          foreach ($file in $Files)
          {
            $sendParams = @{
              'Session' = $Session
              'Path' = $file.FullName
            }
            if ($file.DirectoryName -ne $p) ## It's a subdirectory
            {
              $subdirpath = $file.DirectoryName.Replace("$p\", '')
              $sendParams.Destination = "$Destination\$subDirPath"
            }
            else
            {
              $sendParams.Destination = $Destination
            }
            $sendFileParamColl += $sendParams
          }
          foreach ($paramBlock in $sendFileParamColl)
          {
            Send-File @paramBlock
          }
        }
        else
        {
          Write-Verbose -Message "Starting WinRM copy of [$($p)] to [$($Destination)]"
          # Get the source file, and then get its contents
          $sourceBytes = [System.IO.File]::ReadAllBytes($p);
          $streamChunks = @();
          
          # Now break it into chunks to stream.
          $streamSize = 1MB;
          for ($position = 0; $position -lt $sourceBytes.Length; $position += $streamSize)
          {
            $remaining = $sourceBytes.Length - $position
            $remaining = [Math]::Min($remaining, $streamSize)
            
            $nextChunk = New-Object byte[] $remaining
            [Array]::Copy($sourcebytes, $position, $nextChunk, 0, $remaining)
            $streamChunks +=, $nextChunk
          }
          $remoteScript = {
            if (-not (Test-Path -Path $using:Destination -PathType Container))
            {
              $null = New-Item -Path $using:Destination -Type Directory -Force
            }
            $fileDest = "$using:Destination\$($using:p | Split-Path -Leaf)"
            ## Create a new array to hold the file content
            $destBytes = New-Object byte[] $using:length
            $position = 0
            
            ## Go through the input, and fill in the new array of file content
            foreach ($chunk in $input)
            {
              [GC]::Collect()
              [Array]::Copy($chunk, 0, $destBytes, $position, $chunk.Length)
              $position += $chunk.Length
            }
            
            [IO.File]::WriteAllBytes($fileDest, $destBytes)
            
            Get-Item $fileDest
            [GC]::Collect()
          }
          
          # Stream the chunks into the remote script.
          $Length = $sourceBytes.Length
          $streamChunks | Invoke-Command -Session $Session -ScriptBlock $remoteScript
          Write-Verbose -Message "WinRM copy of [$($p)] to [$($Destination)] complete"
        }
      }
      catch
      {
        Write-Error $_.Exception.Message
      }
    }
  }
}


if ($hostName) {
  $credential = New-Object System.Management.Automation.PSCredential @(
    $userName,
    (ConvertTo-SecureString $password -AsPlainText -Force)
  )

  Write-Host ("Creating session as user '{0}' on host '{1}'" -f $userName, $hostName)
  $session = New-PSSession -ComputerName $hostName -Credential $credential -UseSSL:($useSSL.IsPresent)

  $remoteTempPath = Invoke-Command -Session $session -ScriptBlock { ${Env:Temp} } 2>&1
  Write-Host ("Remote temp path: {0}" -f $remoteTempPath)

  $snapshotsScriptPath = Join-Path -Path $remoteTempPath -ChildPath "snapshots.ps1"
  # TODO: Check if $snapshotsScriptPath actually needs to be $script:scriptDir + "snapshots.ps1"
  #       Check other variables
  Write-Host ("Sending '{0}' to '{1}' via WinRM" -f $snapshotsScriptPath, $remoteTempPath)
  Send-File -Path (Join-Path -Path $script:scriptDir -ChildPath "snapshots.ps1") -Destination $remoteTempPath -Session $session | Out-Null

  $argumentList = @((Join-Path -Path $remoteTempPath -ChildPath "snapshots.ps1"), $scriptName, $parameters)

  Invoke-Command -Session $session `
    -ArgumentList $argumentList `
    -ScriptBlock {
      Set-ExecutionPolicy Bypass -Scope Process
      . $args[0]
      $functionName = $args[1]
      & $functionName -parameters $args[2]
      Remove-Item -Path $args[0] -Force
    } 2>&1
} else {
  Write-Host ("Running '{0}' from '{1}' locally" -f $scriptName, $script:snapshotsScriptPath)
  . $script:snapshotsScriptPath
  & $scriptName -parameters $parameters
}

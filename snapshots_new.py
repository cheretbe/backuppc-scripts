#!/usr/bin/env python3

import sys
import os
import argparse
# import subprocess
import pypsrp.client

def check_winrm_cmd_rc(rc, stderr):
    if rc != 0:
        print("Error executing WinRM command:")
        print(stderr)
        sys.exit(1)

def check_winrm_script_result(streams, had_errors):
    if had_errors:
        print("Error executing PowerShell script:")
        print(streams.error)
        sys.exit(1)

parser = argparse.ArgumentParser(description="Windows Shadow Copy helper script")
parser.add_argument("--cmd-type", required=True, choices=["DumpPreUserCmd", "DumpPostUserCmd"],
                    help="BackupPC command type")
parser.add_argument("--host", required=True, help="host name to create or delete shadow copy on")
parser.add_argument("--username", help="user name for WinRM "
                    "connection (used if --kerberos parameter is not specified)")
parser.add_argument("--password", help="password for WinRM "
                    "connection (used if --kerberos parameter is not specified)")
parser.add_argument("--kerberos", help="Use Kerberos for WinRM connection",
                    action="store_true", default=False)
parser.add_argument("--drives", nargs="+", help="space-delimited list of drive letters", metavar="DRIVE")
parser.add_argument("--share-user", help="user or group name that will have read access to network share(s)")
parser.add_argument("--debug", dest="debug", action="store_true", default=False,
                    help="display extra debug information")

options = parser.parse_args()

#print(options)
#sys.exit(0)

if options.cmd_type == "DumpPreUserCmd":
    if not options.drives:
        print("--drives option is required for DumpPreUserCmd")
        sys.exit(1)
    if not options.share_user:
        print("--share-user option is required for DumpPreUserCmd")
        sys.exit(1)

    drive_list = ""
    for drive in options.drives:
        if drive_list != "":
            drive_list += ", "
        drive_list += "'" + drive[0].upper() + ":'"
    print("Creating shadow copies for drive(s) {} on host '{}'".format(drive_list, options.host), flush=True)

    psScriptParameters = ("-scriptName 'CreateSnapshot' "
        "-parameters @{{drives = @({}); share_user = '{}'}}").format(drive_list, options.share_user)
else:
    print("Deleting shadow copies on host '{}'".format(options.host), flush=True)

    psScriptParameters = "-scriptName 'DeleteSnapshot'"

if options.kerberos:
    print("Kerberos: not implemented")
    sys.exit(1)
else:
    os.environ['REQUESTS_CA_BUNDLE']="/etc/ssl/certs"
    client = pypsrp.client.Client("nosova-1.lan.chere.one",
        username=options.username, password=options.password)

if options.debug:
    print("Getting parameters")
# TODO: (?) Change to OEM codepage
output,streams,had_error = client.execute_ps("${Env:Temp}; [System.Text.Encoding]::Default.CodePage")
check_winrm_script_result(streams, had_error)

# import ipdb
# ipdb.set_trace()

tempPath,encoding = output.splitlines()
if options.debug:
    print("Temp path: {}\nDefault encoding: {}".format(tempPath, encoding))

# TODO: Remove after debug
encoding="866"

localPSScriptPath1 = os.path.join(os.path.dirname(os.path.realpath(__file__)), "snapshots.ps1")
remotePSScriptPath1 = tempPath + "\\" + "snapshots.ps1"
if options.debug:
    print("Uploading '{}' as '{}'".format(localPSScriptPath1, remotePSScriptPath1))
client.copy(localPSScriptPath1, remotePSScriptPath1)

localPSScriptPath2 = os.path.join(os.path.dirname(os.path.realpath(__file__)), "run_snapshot_operation.ps1")
remotePSScriptPath2 = tempPath + "\\" + "run_snapshot_operation.ps1"
if options.debug:
    print("Uploading '{}' as '{}'".format(localPSScriptPath2, remotePSScriptPath2))
client.copy(localPSScriptPath2, remotePSScriptPath2)

# output,streams,had_error = client.execute_ps("${Env:Temp}; [System.Text.Encoding]::Default.CodePage")
# check_winrm_script_result(streams, had_error)

full_cmd = ("powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass "
    ". '{}' ").format(remotePSScriptPath2) + psScriptParameters
if options.debug:
    print("Executing command:")
    print(full_cmd)

stdout,stderr,rc = client.execute_cmd(full_cmd, encoding=encoding)
print(stdout)
check_winrm_cmd_rc(rc, stderr)

# TODO: remove temp files
#!/usr/bin/python3

import sys
import argparse
import subprocess

parser = argparse.ArgumentParser(description="Windows Shadow Copy helper script")
parser.add_argument("--cmd-type", required=True, choices=["DumpPreUserCmd", "DumpPostUserCmd"],
                    help="BackupPC command type")
parser.add_argument("--ssh-host", required=True, help="SSH host name")
parser.add_argument("--ssh-username", required=True, help="SSH user name")
parser.add_argument("--ssh-key", help="Identity (private key) file")
parser.add_argument("--windows-host", help="host name to create or delete shadow copy on")
parser.add_argument("--windows-username", help="user name for WinRM "
                    "connection (used if --windows-host parameter is specified)")
parser.add_argument("--windows-password", help="password for WinRM "
                    "connection (used if --windows-host parameter is specified)")
parser.add_argument("--windows-use-ssl", help="Use SSL for WinRM "
                    "connection (used if --windows-host parameter is specified)",
                    action="store_true", default=False)
parser.add_argument("--drives", nargs="+", help="space-delimited list of drive letters", metavar="DRIVE")
parser.add_argument("--share-user", help="user or group name that will have read access to network share(s)")
parser.add_argument("--debug", dest="debug", action="store_true", default=False,
                    help="display extra debug information")

options = parser.parse_args()

#print(options)
#sys.exit(0)

if options.windows_host:
    if not options.windows_username:
        print("--windows-username option is required when --windows-host is specified")
        sys.exit(1)
    if not options.windows_password:
        print("--windows-password option is required when --windows-host is specified")
        sys.exit(1)
    host_msg = "on host '{}' as user '{}' via '{}'".format(
        options.windows_host, options.windows_username, options.ssh_host)
else:
    host_msg = "on host '{}'".format(options.ssh_host)

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
    print("Creating shadow copies for drive(s) {} ".format(drive_list) + host_msg, flush=True)

    ssh_cmd = ("CALL c:\\backuppc-scripts\\create_snapshot.bat"
        " -parameters @{{drives = @({}); share_user = '{}'}}").format(drive_list, options.share_user)
else:
    print("Deleting shadow copies " + host_msg, flush=True)

    ssh_cmd = "CALL c:\\backuppc-scripts\\delete_snapshot.bat"

if options.windows_host:
    ssh_cmd += (" -hostName " + options.windows_host +
        " -userName " + options.windows_username +
        " -password " + options.windows_password
    )
    if options.windows_use_ssl:
        ssh_cmd += " -useSSL"

ssh_params =("/usr/bin/ssh", "-o", "BatchMode yes",
    (options.ssh_username + "@" + options.ssh_host))
if options.ssh_key:
    ssh_params += ("-i", options.ssh_key)
ssh_params += (ssh_cmd,)

if options.debug:
    print(ssh_params)

subprocess.check_call(ssh_params)

#!/usr/bin/python3

import sys
import argparse
import subprocess

parser = argparse.ArgumentParser(description="Windows Shadow Copy helper script")
parser.add_argument("--host", required=True, help="host name to create or delete shadow copy on")
parser.add_argument("--cmd-type", required=True, choices=["DumpPreUserCmd", "DumpPostUserCmd"], help="DumpPreUserCmd or DumpPostUserCmd")
parser.add_argument("--ssh-proxy", required=True, help="SSH proxy parameters (user@host)")
parser.add_argument("--username", required=True, help="user name for WinRM connections")
parser.add_argument("--password", required=True, help="password")
parser.add_argument("--drives", nargs="+", help="space-delimited list of drive letters", metavar="DRIVE")
parser.add_argument("--share-user", help="user or group name that will have read access to network share(s)")

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
    print("Creating shadow copies for drive(s) {} on host '{}' as user '{}'".format(drive_list, options.host, options.username))

    subprocess.check_call(("/usr/bin/ssh", options.ssh_proxy,
        "CALL c:\\backuppc-scripts\\create_snapshot.bat"
        " -hostName " + options.host +
        " -userName " + options.username +
        " -password " + options.password +
        " -parameters @{{drives = @({}); share_user = '{}'}}".format(drive_list, options.share_user)))
else:
    print("Deleting shadow copies on host '{}' as user '{}'".format(options.host, options.username))

    subprocess.check_call(("/usr/bin/ssh", options.ssh_proxy,
        "CALL c:\\backuppc-scripts\\delete_snapshot.bat"
        " -hostName " + options.host +
        " -userName " + options.username +
        " -password " + options.password))

#!/usr/bin/python3

import sys
import os
import argparse
import subprocess

parser = argparse.ArgumentParser(description="SMB share mounting helper script")
parser.add_argument("action", choices=["mount", "unmount"], help="Action to perform")
parser.add_argument("mountpoint", help="path to mount (e.g. /smb/host/C)")
parser.add_argument("--credentials", help="file that contains username, password and optionally domain")
parser.add_argument("--smb-version", help="SMB protocol version to use (e.g. 2.1)")

options = parser.parse_args()

#print(sys.argv[1], flush=True)
#subprocess.check_call("id")

if options.action == "mount":
    if not options.credentials:
        print("--credentials option is required for mount")
        sys.exit(1)

    if os.path.ismount(options.mountpoint):
        print("[!] WARNING: '{}' is already mounted. Dismounting".format(options.mountpoint))
        subprocess.check_call(("/bin/umount", options.mountpoint))

    os.makedirs(options.mountpoint, exist_ok=True)

    host, drive_letter = options.mountpoint.rstrip("/").split("/")[-2:]
    print("Mounting share 'backup_{}' on host '{}'".format(drive_letter, host), flush=True)

    mount_options = "credentials={},uid=backuppc-client,gid=backuppc-client".format(options.credentials)
    if options.smb_version:
        mount_options += ",vers={}".format(options.smb_version)

    subprocess.check_call(("/bin/mount", "-t", "cifs",
        "-o", mount_options,
        "//{}/backup_{}".format(host, drive_letter),
        options.mountpoint
    ))
else:
    print("Dismounting '{}'".format(options.mountpoint), flush=True)
    subprocess.check_call(("/bin/umount", options.mountpoint))

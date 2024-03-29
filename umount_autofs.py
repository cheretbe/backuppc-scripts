#!/usr/bin/python3

import os
import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mountpoint", help="Autofs CIFS mountpoint (e.g. /smb/hostname/C)")
    options = parser.parse_args()

    # Strip trailing slash if present
    if options.mountpoint.endswith(os.sep):
        options.mountpoint = options.mountpoint[:-1]

    with open("/proc/mounts", "r") as mounts_f:
        for mount in mounts_f:
            # /proc/mounts format is the same as of /etc/fstab
            # https://linux.die.net/man/5/fstab
            # 2nd value is mount point, 3rd is filesystem type
            mountpoint, fstype = [mount.split(" ")[i] for i in (1, 2)]
            if (options.mountpoint.startswith(mountpoint)) and (fstype == "cifs"):
                print(f"Unmounting CIFS filesystem at {mountpoint}", flush=True)
                subprocess.check_call(
                    ["/usr/bin/sudo", "-n", "/bin/umount", "-t", "cifs", mountpoint]
                )

if __name__ == "__main__":
    main()

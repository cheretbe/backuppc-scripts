#!/usr/bin/python3

import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mountpoint", help="Autofs CIFS mountpoint (e.g. /smb/hostname/C)")
    options = parser.parse_args()

    with open("/proc/mounts", "r") as mounts_f:
        for mount in mounts_f:
            # /proc/mounts format is the same as of /etc/fstab
            # https://linux.die.net/man/5/fstab
            # 2nd value is mount point, 3rd is filesystem type
            mountpoint, fstype = [mount.split(" ")[i] for i in (1, 2)]
            if (mountpoint == options.mountpoint) and (fstype == "cifs"):
                print(f"Unmounting CIFS filesystem at {mountpoint}", flush=True)
                subprocess.check_call(
                    ["/usr/bin/sudo", "-n", "/bin/umount", mountpoint, "-t", "cifs"]
                )

if __name__ == "__main__":
    main()

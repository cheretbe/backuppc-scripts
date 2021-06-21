#!/usr/bin/env python3

import sys
import os
import argparse
import pypsrp.client

def check_winrm_script_result(streams, had_error):
    if had_error:
        print("Error executing PowerShell script:")
        for error_rec in streams.error:
            print(str(error_rec.exception))
        sys.exit(1)

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Windows Shadow Copy helper script"
        # formatter_class=argparse.RawTextHelpFormatter,
        # epilog="test1\ntest2"
    )
    parser.add_argument("host", help="host name to create or delete shadow copy on")
    parser.add_argument(
        "--cmd", required=True, choices=["create", "delete"],
        help="Snapshot operation command"
    )
    parser.add_argument(
        "--connection", choices=["ssl", "kerberos", "unencrypted"], default="ssl",
        help="Connection type (default: ssl)")
    parser.add_argument(
        "--username", help="The username to connect with (not used with 'kerberos' connection)")
    parser.add_argument(
        "--password", help="The password for username (not used with 'kerberos' connection)"
    )
    parser.add_argument(
        "--drives", nargs="+", metavar="DRIVE",
        help="space-delimited list of drive letters (required for 'create' command)"
    )
    parser.add_argument(
        "--share-user",
        help=(
            "user or group name that will have read access to network share(s) "
            "(required for 'create' command)"
        )
    )
    parser.add_argument(
        "--debug", dest="debug", action="store_true", default=False,
        help="display extra debug information"
    )

    return parser.parse_args()

#print(options)
#sys.exit(0)

def main():
    options = parse_arguments()

    if options.cmd == "create":
        if not options.drives:
            print("--drives option is required for 'create' command")
            sys.exit(1)
        if not options.share_user:
            print("--share-user option is required for 'create' command")
            sys.exit(1)

        drive_list = ""
        for drive in options.drives:
            if drive_list != "":
                drive_list += ", "
            drive_list += "'" + drive[0].upper().replace(":", "") + ":'"
        print(
            f"Creating shadow copies for drive(s) {drive_list} on host '{options.host}'",
            flush=True
        )

        snapshot_command = (
            "& CreateSnapshot "
            f"-parameters @{{drives = @({drive_list}); share_user = '{options.share_user}'}}")
    else:
        print(f"Deleting shadow copies on host '{options.host}'", flush=True)

        snapshot_command = "& DeleteSnapshot"

    if options.connection == "kerberos":
        sys.exit("Kerberos: not implemented")
    elif options.connection == "ssl":
        os.environ['REQUESTS_CA_BUNDLE'] = "/etc/ssl/certs"
        client = pypsrp.client.Client(
            options.host,
            username=options.username, password=options.password
        )
    else:
        client = pypsrp.client.Client(
            options.host,
            ssl=False, encryption="never", auth="basic",
            username=options.username, password=options.password
        )

    if options.debug:
        print("Getting temp path", flush=True)
    output, streams, had_error = client.execute_ps("${Env:Temp}")
    check_winrm_script_result(streams, had_error)
    temp_path = output
    if options.debug:
        print("Temp path: {}".format(temp_path), flush=True)

    local_psscript_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "snapshots.ps1")
    remote_psscript_path = temp_path + "\\" + "snapshots.ps1"
    if options.debug:
        print(f"Uploading '{local_psscript_path}' as '{remote_psscript_path}'", flush=True)
    client.copy(local_psscript_path, remote_psscript_path)

    if options.debug:
        print(snapshot_command, flush=True)

    output, streams, had_error = client.execute_ps(f"""
        Set-ExecutionPolicy Bypass -Scope Process -Force
        . {remote_psscript_path}
        {snapshot_command}
    """)
    print(output, flush=True)
    check_winrm_script_result(streams, had_error)

    if options.debug:
        print("Deleting '{}'".format(remote_psscript_path), flush=True)
    client.execute_ps("Remove-Item -Path {} -Force".format(remote_psscript_path))

if __name__ == "__main__":
    main()

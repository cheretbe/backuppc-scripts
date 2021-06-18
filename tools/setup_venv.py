#!/usr/bin/env python3

import os
import sys
import argparse
import subprocess

# https://stackoverflow.com/questions/3041986/apt-command-line-interface-like-yes-no-input/3041990#3041990
def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
            It must be "yes" (the default), "no" or None (meaning
            an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True, "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == "":
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' " "(or 'y' or 'n').\n")

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Wrapper script for Python virtual environments creation"
    )
    parser.add_argument(
        "venv_name",
        help="Virtual environments (relative to ~/.cache/venv/, not full path)"
    )
    parser.add_argument(
        "-r", "--requirement", default=None,
        help="Install additional pip packages from the given requirements file"
    )
    parser.add_argument(
        "-b", "--batch-mode", action="store_true", default=False,
        help="Batch mode (disables all prompts)"
    )
    options = parser.parse_args()
    if os.path.sep in options.venv_name:
        sys.exit("ERROR: virtual environment name should be a directory name, not full path")

    return options

def main():
    options = parse_arguments()

    venv_path = os.path.expanduser(f"~/.cache/venv/{options.venv_name}")
    if os.path.isdir(venv_path):
        sys.exit(0)

    if not options.batch_mode:
        print("A Python 3 virtual environment needs to be created for this script to run")
        if not query_yes_no("Would you like to setup the venv now?"):
            sys.exit("Cancelled by user")
    print(f"Creating venv '{venv_path}'")

    print("Checking installed packages")
    apt_packages_to_install = []
    # TODO: Do we actually need build-essential?
    for apt_package in ("build-essential", "python3-venv", "python3-dev"):
        if (subprocess.run( #pylint: disable=subprocess-run-check
                ["/usr/bin/dpkg-query", "-s", apt_package],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
        )).returncode != 0:
            apt_packages_to_install += [apt_package]

    if len(apt_packages_to_install) != 0:
        print(f"The following apt packages need to be installed: {apt_packages_to_install}")
        print("Updating apt package list")
        sudo_cmd = ["/usr/bin/sudo"]
        if options.batch_mode:
            sudo_cmd += ["-n"]
        sudo_cmd += ["--", "sh", "-c"]
        if options.batch_mode:
            apt_cmd = ["DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -qq update"]
        else:
            apt_cmd = ["/usr/bin/apt-get update"]
        print(sudo_cmd + apt_cmd)
        subprocess.check_call(sudo_cmd + apt_cmd)

        print("Installing packages")
        # Convert to space-separated list
        apt_packages_to_install = " ".join(apt_packages_to_install)
        if options.batch_mode:
            apt_cmd = [
                (
                    "DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -y -qq "
                    f"install {apt_packages_to_install}"
                )
            ]
        else:
            apt_cmd = [f"/usr/bin/apt-get update {apt_packages_to_install}"]
        print(sudo_cmd + apt_cmd)
        subprocess.check_call(sudo_cmd + apt_cmd)

    print(["/usr/bin/python3", "-m", "venv", venv_path])
    subprocess.check_call(["/usr/bin/python3", "-m", "venv", venv_path])
    pip_cmd = (
        f". {venv_path}/bin/activate &&\n"
        "pip3 install wheel &&\n"
        "pip3 install --upgrade pip &&\n"
    )
    if options.requirement is not None:
        pip_cmd += f"pip3 install -r {options.requirement} &&\n"
    pip_cmd += "deactivate"
    pip_env = os.environ.copy()
    if "/usr/bin" not in pip_env["PATH"].split(os.pathsep):
        pip_env["PATH"] += f"{os.pathsep}/usr/bin"
    print(pip_cmd)
    subprocess.check_call(pip_cmd, shell=True, env=pip_env)


if __name__ == "__main__":
    main()

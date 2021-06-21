#!/usr/bin/env python3

import argparse
import os
import sys
import tempfile
import subprocess
import shutil

parser = argparse.ArgumentParser(description="Edit BackupPC config file in UTF-8")
parser.add_argument("src_file", help="Config file name")

options = parser.parse_args()

EDITOR_var = os.environ.get("EDITOR", "nano")

with open(options.src_file, "r") as f:
    filedata = f.read()

original_text = ""
token = ""
code = ""
i = 0
data_len = len(filedata)

while i < data_len:
    if filedata[i] == "}" and token:
        original_text += chr(int(code, 16))
        code = ""
        token = ""
        i += 1
        continue
    if token:
        code += filedata[i]
        i += 1
        continue
    if filedata[i:i+3] == "\\x{":
        token = "\\x{"
        i += 3
        continue
    original_text += filedata[i]
    i += 1

with tempfile.NamedTemporaryFile(mode="w+", suffix=".tmp") as tf:
    tf.write(original_text)
    tf.flush()
    subprocess.call([EDITOR_var, tf.name])

    tf.seek(0)
    edited_text = tf.read()

if edited_text == original_text:
    print("No changes. Skipping update")
    sys.exit(0)

output = ""
for char in edited_text:
    try:
        char.encode("iso-8859-1")
        output_char = char
    except UnicodeEncodeError:
        output_char = "\\x{" + format(ord(char), "0X").lower() + "}"
    output += output_char

print("Saving original file as " + options.src_file + ".bak")
shutil.copyfile(options.src_file, options.src_file + ".bak")

print("Updating " + options.src_file)
with open(options.src_file, "w") as f:
    f.write(output)

"""SAST example — intentionally vulnerable code for opengrep / codeql.

A remote (HTTP) user input flows into a shell command, which is a classic
command-injection taint flow that both scanners flag. Test fixture only.
"""
import subprocess

from flask import Flask, request

app = Flask(__name__)


@app.route("/run")
def run():
    cmd = request.args.get("cmd")
    # Vulnerable: untrusted input passed to a shell
    return subprocess.check_output(cmd, shell=True)
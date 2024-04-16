"""Script to install PyTorch based on "COMPUTE_DEVICE" environment variable.

Possible values: "cuda", "rocm", "cpu"

Advice: "pciutils" package should be installed inside container,
it can be used in a very rare cases to perform autodetect of hardware.

If an additional argument is specified, the script considers this to be the file name of the ExApp entry point.

Remember to adjust it with anything your ExApp need of and add it here or a separately.

Copyright (c) 2024 Alexander Piskun, Nextcloud
"""

# pylint: disable=consider-using-with

import os
import subprocess
import sys
import typing
from pathlib import Path


def hw_autodetect() -> typing.Literal["cuda", "rocm", "cpu"]:
    process = subprocess.Popen(
        "lspci",  # noqa: S607
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        shell=True,  # noqa: S602
    )
    output, errors = process.communicate()
    if process.returncode != 0:
        print("hw_install: Error running lspci:", flush=True)
        print(errors, flush=True)
        return "cpu"
    for line in output.split("\n"):
        if line.find("VGA") != -1:
            if line.find("NVIDIA") != -1:
                return "cuda"
            if line.find("AMD") != -1:
                return "rocm"
    return "cpu"


def hw_install():
    defined_accelerator = os.environ.get("COMPUTE_DEVICE", "")
    if not defined_accelerator:
        defined_accelerator = hw_autodetect()

    if defined_accelerator == "cpu":
        requirements = "torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu"
    elif defined_accelerator == "rocm":
        # TO-DO: upcoming PyTorch 2.3 will have ROCM 6.0 by default
        requirements = "--pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.0"
    else:
        requirements = "torch torchvision torchaudio"

    process_args = [sys.executable, "-m", "pip", "install", "--force-reinstall", "--no-deps", *requirements.split()]
    subprocess.run(
        process_args,  # noqa: S603
        check=False,
        stdin=sys.stdin,
        stdout=sys.stdout,
        stderr=sys.stderr,
    )


if __name__ == "__main__":
    # we do not want to reinstall "PyTorch" each time the container starts
    flag_file = Path("/.installed_flag")
    if not flag_file.exists():
        print("hw_install: perform installation", flush=True)
        hw_install()
        flag_file.touch()
    if len(sys.argv) <= 1:
        print("hw_install: exit", flush=True)
        sys.exit(0)
    # execute another script if needed
    print(f"hw_install: executing additional script: {sys.argv[1]}", flush=True)
    r = subprocess.run(
        [sys.executable, sys.argv[1]],  # noqa: S603
        stdin=sys.stdin,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=False,
    )
    sys.exit(r.returncode)

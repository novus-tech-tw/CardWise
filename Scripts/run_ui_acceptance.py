#!/usr/bin/env python3
"""Run screenshot-only UI acceptance and open offer links from the Simulator host."""

import argparse
import codecs
import json
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import threading
import time
from urllib.parse import parse_qs, urlsplit
from uuid import UUID
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
REQUEST = re.compile(r"CARDWISE_TEST_OPEN_URL ([0-9A-Fa-f-]+) (\S+)")


def validate_offer_url(url):
    parts = urlsplit(url)
    params = parse_qs(parts.query)
    if parts.scheme != "cardwise" or parts.netloc != "offers" or parts.path or parts.fragment:
        raise ValueError("Only saved-offer test URLs are supported")
    if set(params) != {"wallet", "offer"} or any(len(values) != 1 for values in params.values()):
        raise ValueError("A single wallet and offer are required")
    for values in params.values():
        UUID(values[0])


def run(device, result_bundle, timeout):
    UUID(device)
    scheme = ROOT / "CardWise.xcodeproj/xcshareddata/xcschemes/CardWiseUI.xcscheme"
    action = ET.parse(scheme).getroot().find("TestAction")
    if action.get("preferredScreenCaptureFormat") != "screenshots" or action.get("systemAttachmentLifetime") != "keepNever":
        raise ValueError("Generate the screenshot-only CardWiseUI scheme before running acceptance")
    result = Path(result_bundle)
    if not result.is_absolute():
        result = ROOT / result
    if result.exists():
        raise ValueError("The result bundle already exists; choose a new path")
    result.parent.mkdir(parents=True, exist_ok=True)
    command = [
        "xcodebuild", "test", "-project", "CardWise.xcodeproj", "-scheme", "CardWiseUI",
        "-destination", f"platform=iOS Simulator,id={device}", "-resultBundlePath", str(result),
        "-parallel-testing-enabled", "NO", "-collect-test-diagnostics", "never",
        "-test-timeouts-enabled", "YES", "-default-test-execution-time-allowance", "300",
        "-maximum-test-execution-time-allowance", "360", "CODE_SIGNING_ALLOWED=YES", "CODE_SIGN_IDENTITY=-",
    ]
    process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               bufsize=0, start_new_session=True)
    finished = threading.Event()
    expired = threading.Event()
    stop_lock = threading.Lock()

    def stop_owned_process():
        with stop_lock:
            for signum, grace in [(signal.SIGINT, 10), (signal.SIGTERM, 5), (signal.SIGKILL, 5)]:
                if process.poll() is not None:
                    return
                try:
                    os.killpg(process.pid, signum)
                except ProcessLookupError:
                    return
                try:
                    process.wait(timeout=grace)
                    return
                except subprocess.TimeoutExpired:
                    continue

    def deadline():
        if not finished.wait(timeout):
            expired.set()
            print("UI acceptance exceeded its overall deadline; stopping the owned xcodebuild group", flush=True)
            stop_owned_process()

    def cancelled(signum, _frame):
        finished.set()
        stop_owned_process()
        raise SystemExit(128 + signum)

    previous_handlers = {signum: signal.getsignal(signum) for signum in (signal.SIGINT, signal.SIGTERM)}
    for signum in previous_handlers:
        signal.signal(signum, cancelled)
    threading.Thread(target=deadline, daemon=True).start()
    requests = set()

    def consume(line):
        print(line, end="", flush=True)
        match = REQUEST.search(line)
        if not match:
            return
        token, url = match.groups()
        UUID(token)
        if token in requests:
            return
        validate_offer_url(url)
        if len(requests) >= 2:
            raise ValueError("Unexpected additional offer navigation request")
        requests.add(token)
        subprocess.run(["xcrun", "simctl", "openurl", device, url], check=True, timeout=20)
        print(f"Opened saved-offer test URL {len(requests)}/2 through simctl", flush=True)

    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    decoder = codecs.getincrementaldecoder("utf-8")("replace")
    pending = ""
    exited_at = None
    try:
        while not expired.is_set():
            ready = selector.select(timeout=1)
            if ready:
                data = os.read(process.stdout.fileno(), 65536)
                if not data:
                    break
                pending += decoder.decode(data)
                while "\n" in pending:
                    line, pending = pending.split("\n", 1)
                    consume(line + "\n")
            if process.poll() is not None:
                exited_at = exited_at or time.monotonic()
                # Do not let an orphaned logging child keep the host pipe open forever.
                if time.monotonic() - exited_at >= 2:
                    break
        if pending:
            consume(pending)
        code = process.wait(timeout=25)
        if expired.is_set():
            return 124
        if code == 0 and len(requests) != 2:
            raise ValueError("Acceptance did not exercise both offer URL requests")
        if code == 0:
            summary = subprocess.run(
                ["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", str(result), "--format", "json"],
                capture_output=True, text=True, check=True, timeout=30,
            )
            result_summary = json.loads(summary.stdout)
            if result_summary.get("result") != "Passed" or result_summary.get("failedTests") != 0 or result_summary.get("passedTests", 0) < 2:
                raise ValueError("The completed result bundle does not prove both UI cases passed")
            print("Completed UI result verified; both offer URL requests were exercised", flush=True)
        return code
    finally:
        finished.set()
        stop_owned_process()
        selector.close()
        process.stdout.close()
        for signum, handler in previous_handlers.items():
            signal.signal(signum, handler)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="UUID of an owned Simulator")
    parser.add_argument("--result-bundle", required=True)
    parser.add_argument("--timeout", type=int, default=1080, help="Overall test deadline in seconds")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    return run(args.device, args.result_bundle, args.timeout)


if __name__ == "__main__":
    raise SystemExit(main())

"""Exercise the host bridge with real child processes, without a Simulator."""

import json
import os
from pathlib import Path
import sys
import time

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import run_ui_acceptance as bridge

DEVICE = "11111111-1111-4111-8111-111111111111"
OFFER_URL = "cardwise://offers?wallet=22222222-2222-4222-8222-222222222222&offer=33333333-3333-4333-8333-333333333333"


def prepare(tmp_path, monkeypatch, driver):
    scheme = tmp_path / "CardWise.xcodeproj/xcshareddata/xcschemes/CardWiseUI.xcscheme"
    scheme.parent.mkdir(parents=True)
    scheme.write_text('<Scheme><TestAction preferredScreenCaptureFormat="screenshots" systemAttachmentLifetime="keepNever"/></Scheme>')
    binaries = tmp_path / "bin"
    binaries.mkdir()
    xcode = binaries / "xcodebuild"
    xcode.write_text("#!" + sys.executable + "\n" + driver)
    xcode.chmod(0o755)
    xcrun = binaries / "xcrun"
    xcrun.write_text("#!" + sys.executable + "\n" + '''
import json, os, sys
if sys.argv[1:3] == ['simctl', 'openurl']:
    with open(os.environ['BRIDGE_TEST_LOG'], 'a') as output:
        output.write(json.dumps(sys.argv[1:]) + '\\n')
elif sys.argv[1] == 'xcresulttool':
    print(json.dumps({'result': 'Passed', 'failedTests': 0, 'passedTests': 2}))
else:
    raise SystemExit(2)
''')
    xcrun.chmod(0o755)
    monkeypatch.setattr(bridge, "ROOT", tmp_path)
    monkeypatch.setenv("PATH", str(binaries) + os.pathsep + os.environ["PATH"])
    monkeypatch.setenv("BRIDGE_TEST_LOG", str(tmp_path / "requests.jsonl"))


def test_real_process_bridge_opens_each_request_once_and_preserves_results(tmp_path, monkeypatch):
    driver = '''
import pathlib, sys
result = pathlib.Path(sys.argv[sys.argv.index('-resultBundlePath') + 1])
result.mkdir()
'''
    first = "CARDWISE_TEST_OPEN_URL 44444444-4444-4444-8444-444444444444 " + OFFER_URL
    second = "CARDWISE_TEST_OPEN_URL 55555555-5555-4555-8555-555555555555 " + OFFER_URL
    driver += "print(" + repr(first) + ", flush=True)\n"
    driver += "print(" + repr(first) + ", flush=True)\n"
    driver += "print(" + repr(second) + ", flush=True)\n"
    prepare(tmp_path, monkeypatch, driver)
    result = tmp_path / "acceptance.xcresult"
    assert bridge.run(DEVICE, result, timeout=10) == 0
    requests = [json.loads(line) for line in (tmp_path / "requests.jsonl").read_text().splitlines()]
    assert requests == [["simctl", "openurl", DEVICE, OFFER_URL]] * 2
    with pytest.raises(ValueError, match="already exists"):
        bridge.run(DEVICE, result, timeout=10)


def test_deadline_stops_a_stalled_owned_driver(tmp_path, monkeypatch):
    prepare(tmp_path, monkeypatch, "import time\ntime.sleep(30)\n")
    start = time.monotonic()
    assert bridge.run(DEVICE, tmp_path / "stalled.xcresult", timeout=0.1) == 124
    assert time.monotonic() - start < 10


@pytest.mark.parametrize("url", [
    "https://example.com/", "cardwise://credits", OFFER_URL + "&offer=33333333-3333-4333-8333-333333333333",
    "cardwise://offers?wallet=missing&offer=33333333-3333-4333-8333-333333333333",
])
def test_host_cannot_open_unrelated_or_ambiguous_urls(url):
    with pytest.raises(ValueError):
        bridge.validate_offer_url(url)

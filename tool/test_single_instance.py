"""Native process smoke test. Use a private D-Bus session on Linux:

dbus-run-session -- python3 tool/test_single_instance.py /path/to/doever
On Windows, run on an isolated test account (as in the Windows CI job).
"""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time


def main():
    executable = Path(sys.argv[1]).resolve(strict=True)
    processes = []
    with tempfile.TemporaryDirectory(prefix="doever-instance-test-") as data:
        env = os.environ.copy()
        env.update(XDG_DATA_HOME=data, XDG_CONFIG_HOME=data)

        def start():
            process = subprocess.Popen(
                [str(executable)], cwd=executable.parent, env=env,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
            processes.append(process)
            return process

        def stop(process):
            if process.poll() is None:
                process.kill()
            process.wait(timeout=10)

        try:
            first = start()
            time.sleep(3)
            assert first.poll() is None, "First launch exited unexpectedly"
            for _ in range(3):
                duplicate = start()
                assert duplicate.wait(timeout=10) == 0, "Duplicate failed to exit cleanly"
                assert first.poll() is None, "Duplicate closed the original process"
            stop(first)

            # Launch at the same time after an abrupt exit: no stale lock, and
            # the winner must be selected atomically rather than by process scan.
            contenders = [start(), start()]
            deadline = time.monotonic() + 10
            while all(p.poll() is None for p in contenders) and time.monotonic() < deadline:
                time.sleep(0.1)
            survivors = [p for p in contenders if p.poll() is None]
            assert len(survivors) == 1, "Concurrent launches did not leave exactly one instance"
            assert all(p.poll() in (None, 0) for p in contenders), "Secondary launch failed"
            time.sleep(3)
            assert survivors[0].poll() is None, "Restarted instance exited unexpectedly"
            print("PASS: duplicate launches, concurrent startup, and restart after termination")
        finally:
            for process in processes:
                stop(process)


if __name__ == "__main__":
    main()

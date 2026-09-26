# Desktop executables

A Flutter desktop application is a bundle: keep the executable beside its
`data/` directory and shared libraries. Do not distribute the executable alone.
These scripts produce release builds and archives under the ignored `build/` directory.

## Generated packages

Both packages are available locally after this build:

- `build/releases/doever-linux-x64.tar.gz`
- `build/releases/doever-windows-x64.zip`

SHA-256 files and `BUILD_INFO.txt` are beside the archives. Linux was built and
launched on Ubuntu 26.04 x86_64. Windows was built successfully on its native
[GitHub Actions runner](https://github.com/felipilloff/doever_app/actions/runs/36227397981);
its native process smoke test passed in CI. Foreground focus has not been visually
verified on Windows.

## Notes

These packages include local Notes for Windows and Linux: independent blocks,
autosave, session undo/redo, search, managed images and TODO-to-task creation.
The first launch upgrades schema v1 to v2 by adding Notes tables and indexes;
existing task/list/reminder data is preserved. See [Notes architecture](ARCHITECTURE.md#notes-desktop-module)
and [validation coverage](VALIDATION.md#notes--pages-update).

## Workspace background

Windows and Linux expose **Settings → Workspace background** with a native file
chooser, live preview, and change/remove actions. Static PNG, JPEG and WebP files
up to 20 MB and 40 megapixels are accepted; animated files are rejected. Images
are normalized to PNG with a longest edge of at most 2560 pixels and saved under
`backgrounds/` in the application support directory. Only the managed copy is
removed when changing/resetting this preference. The original image is untouched.
The selected background is local to the installation and persists across launches.

## Single instance

Windows and Linux allow one instance per graphical desktop session, including
launches from different extracted copies of the package. A second launch exits
and asks the existing window to restore/activate. Foreground focus ultimately
follows the desktop window manager's rules. Close old versions before testing an
updated package: older executables do not participate in this guard.

Linux uses [GTK/GApplication uniqueness](https://docs.gtk.org/gio/class.Application.html)
via the desktop's D-Bus session. Windows keeps a
[named mutex](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createmutexw)
alive for the entire process lifetime. The OS releases ownership on exit/crash.

Run the process regression check with temporary Linux data and a private bus:

```sh
dbus-run-session -- python3 tool/test_single_instance.py build/linux/x64/release/bundle/doever
```

Windows CI runs the same check against the release EXE on its isolated runner:

```powershell
python tool/test_single_instance.py build/windows/x64/runner/Release/doever.exe
```

The check covers duplicate launches, simultaneous startup, and reopening after
abrupt process termination. It does not assert foreground focus or minimization.

## Linux x86_64

Install build prerequisites on Ubuntu/Debian:

```sh
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
bash tool/build_linux.sh
```

Run the local build:

```sh
./build/linux/x64/release/bundle/doever
```

To move it to another compatible Linux machine, copy
`build/releases/doever-linux-x64.tar.gz`, extract it into its own directory,
and run `./doever` inside that directory. The archive preserves executable bits.
GTK 3 and the system libraries listed by `ldd doever` must be installed.
A build made on a newer Linux distribution is not guaranteed to run on older
glibc versions; build on the oldest distribution you intend to support.

## Windows x64

On Windows, install Flutter and Visual Studio's **Desktop development with C++**
workload, then run from PowerShell:

```powershell
./tool/build_windows.ps1
./build/windows/x64/runner/Release/doever.exe
```

Distribute `build/releases/doever-windows-x64.zip`. Extract the entire ZIP before
opening `doever.exe`. Target machines may require the Microsoft Visual C++
2015–2022 x64 Redistributable. This is an unsigned portable application, not an
installer or an MSIX package. Removing already displayed Windows notifications
requires package identity; pending reminders are cancellable without it.

Flutter builds the Windows runner on Windows, not on a Linux host. The existing
[Platform builds workflow](https://github.com/felipilloff/doever_app/actions/workflows/platforms.yml)
provides a Windows build machine. Run it on the desired branch and download its
`windows-release` artifact; extract the whole artifact and open `doever.exe`.
The existing workflow also builds an Android debug APK.

With GitHub CLI authenticated:

```sh
gh workflow run platforms.yml --ref main
gh run list --workflow platforms.yml
gh run watch <run-id> --exit-status
gh run download <run-id> --name windows-release --dir build/releases/windows-x64
```

The workflow builds the committed source on the selected branch. Uncommitted local
changes are not included. Neither local build script publishes or uploads files.

References: [Flutter Linux setup](https://docs.flutter.dev/platform-integration/linux/setup),
[Flutter desktop build hosts](https://docs.flutter.dev/platform-integration), and
[Windows deployment](https://docs.flutter.dev/platform-integration/windows/building).

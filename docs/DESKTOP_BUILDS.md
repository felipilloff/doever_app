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
[GitHub Actions runner](https://github.com/felipilloff/doever_app/actions/runs/36159427380);
its desktop UI has not been run on this Linux host.

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

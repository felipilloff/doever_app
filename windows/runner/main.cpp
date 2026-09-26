#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Keep the named handle alive until after the window is destroyed. Windows
  // releases it even after a crash, so there is no stale lock file to remove.
  const HANDLE handle = ::CreateMutexW(
      nullptr, FALSE, L"Local\\app.doever.doever.single_instance");
  const DWORD mutex_error = ::GetLastError();
  const std::unique_ptr<void, decltype(&::CloseHandle)> instance_mutex(
      handle, &::CloseHandle);
  if (!instance_mutex) {
    return EXIT_FAILURE;
  }
  if (mutex_error == ERROR_ALREADY_EXISTS) {
    // The first launch may still be creating its native window.
    for (int attempt = 0; attempt < 40; ++attempt) {
      HWND existing = ::FindWindowW(kDoeverWindowClassName, nullptr);
      if (existing != nullptr) {
        if (::IsIconic(existing)) {
          ::ShowWindowAsync(existing, SW_RESTORE);
        }
        ::SetForegroundWindow(existing);
        break;
      }
      ::Sleep(50);
    }
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Doever", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

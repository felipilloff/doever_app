# Doever development TODO

## Completed features

- [x] Tasks, My Day, Important, Planned, custom lists, steps and search.
- [x] Local reminders with retries and recurring tasks.
- [x] Desktop Notes: blocks, autosave, history, search and TODO-to-task creation.
- [x] Theme Studio: semantic layers, gradients, presets, local themes and import/export.
- [x] Five interface languages, desktop backgrounds and single-instance desktop launch.

## Focus v1 — completed

- [x] Windows/Linux navigation, full mixer and persistent mini player.
- [x] Testable SoLoud adapter, four colored noises, thirteen licensed field recordings and synthesized vinyl.
- [x] Eight-track mixing, independent/master volume, mute, pause/resume, loops and fades.
- [x] Bounded Dynamic Ambience and soundscape crossfades.
- [x] Six built-in presets, custom soundscape CRUD and local preferences.
- [x] Theme Studio gradients, keyboard access and five-language interface.
- [x] Additive v4 migration, playback/persistence/widget/integration tests.
- [x] Audio provenance, reproducible recording preparation and redistribution notices.
- [x] Native Linux engine verification and navigation/restart integration.
- [x] Native Windows application workflow and verified Windows/Linux release packages.

## Focus v2 — implemented

- [x] UUID Focus Sessions, simple timers and configurable Pomodoro.
- [x] Short/long breaks, configurable interval and opt-in auto-start per phase.
- [x] Start Focus from task details; optional task completion through TaskRepository.
- [x] Quick Focus (Ctrl+Shift+F), active-task search and taskless sessions.
- [x] Per-session soundscape selection and last-used soundscape memory.
- [x] App-owned monotonic timer, pause/resume, early finish and cancellation.
- [x] Navigation-safe session indicator and quick return alongside the v1 player.
- [x] Local history with title snapshots that survive task deletion.
- [x] Additive Drift v5 migration and safe interrupted-session recovery.
- [x] Theme Studio layers/gradients and keyboard-accessible timer controls.
- [x] Completion notifications through the existing adapter (Windows/Linux).
- [x] Windows/Linux feature gate and desktop widget variants.
- [x] Linux release build, deterministic timer/repository/migration/widget/theme tests.
- [ ] Native Windows v2 runtime/build validation and physical OS notification delivery.
- [x] Native Linux task/session/navigation/restart integration (X11 software rendering).

## Focus v3 — Analytics and Insights

- [ ] Daily, weekly and monthly Focus time; completed-session counts.
- [ ] Task-linked analytics and task-detail Focus summaries.
- [ ] Charts, Focus goals and productivity history.
- [ ] Preferred soundscape insights and Focus heatmap.
- [ ] Historical filtering, export and session tags/categories.
- [ ] History pagination beyond the latest 100 entries (older data is retained).

## Future ideas and deferred decisions

- [ ] Licensed lo-fi music, user-imported audio and optional sound packs.
- [ ] Richer ambience, day/night switching and a dedicated minimal/fullscreen Focus window.
- [ ] Always-on-top mini timer and per-task preferred soundscapes.
- [ ] Global shortcuts, calendar integration, scheduling and session templates.
- [ ] Optional mobile companion, integrations and future sync.
- [ ] System tray/media-session controls, sleep timer and optional end chime.
- [ ] Decide on distribution signing/installers and older Linux compatibility.

## Technical debt / manual validation

- [ ] Native file dialogs, OS notification delivery and assistive technology on target hardware.
- [ ] Maintain audio listening checks alongside automated signal/engine tests.
- [ ] Verify physical Windows audio output on target hardware; CI has no playback device.
- [ ] Translate new Focus v2 session copy into the existing five-language catalogs.
- [ ] Refine conservative sleep detection: gaps over 15 seconds pause without counting the gap; crash recovery retains only the last saved transition.
- [ ] Optional end chime and pause-audio preference; ambience currently stays independent.

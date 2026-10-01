# Focus v1 architecture decisions

Focus is a Windows/Linux feature. A Riverpod application-scoped player owns a
lazy SoLoud adapter; routes only display/control it. The mini player sits below
the routed workspace so Notes, Settings and Tasks share one playback instance.
The native library is never initialized before explicit Play, nor on other targets.

Pure Dart soundscape/track models and an AudioEngine contract isolate FFI handles.
Drift v4 adds soundscapes plus a singleton playback-preferences row to the existing
database. Only selections, mixes and volume preferences persist; playback never
autostarts. Structural operations are serialized, slider persistence is debounced,
and shutdown flushes pending preferences before releasing the engine.

Up to eight tracks play concurrently. Per-voice headroom bounds the sum, including
crossfades and Dynamic Ambience. Fades/modulation run in SoLoud, not a Flutter
animation loop. Sources are loaded only as needed and unused sources are released.
Each mono source peaks at 0.65; per-voice gain is 0.09. Even sixteen voices
during a two-bank transition remain below full scale at maximum master volume.
Dynamic Ambience oscillates between 88–112% of the chosen track volume, clamped
to 0–1, with a 23–36 second period. A switch first loads its next bank, then
crossfades for 600 ms; a failed load retains the previous audible mix.

Soundscape JSON is confined to the data codec; the domain uses immutable typed
tracks. Custom entries and the last working mix are separate: explicit Save
updates the library; 450 ms debounced preferences preserve the current working
mix, master volume and mute. No voice handles or playing state are serialized.
The existing schema-v1/v2/v3 snapshots are migrated additively to v4, with exact
legacy-row comparisons in tests. Focus never writes to Tasks, Notes or themes.

Thirteen environmental loops use licensed field recordings; vinyl remains a
procedural texture. `tool/prepare_focus_recordings.py` verifies source checksums,
downmixes/resamples to mono 44.1 kHz PCM16, removes DC and overlaps boundaries
for 24-second loops, soft-limits transients and retains the engine's 0.65 peak
ceiling. Short recordings
also overlap when repeated. Source URLs, licenses, offsets and hashes are in
`assets/audio/recordings.json`; credits ship with the desktop packages.
White, pink, brown and approximate
grey noise are generated on demand in an isolate. See assets/audio/ATTRIBUTION.md.
The grey approximation emphasizes low and high bands around restrained mids;
it does not claim calibrated equal loudness. Pink uses sixteen octave rows of
Voss–McCartney plus a white component; brown uses a bounded leaky integrator.
The generated noise tail overlaps its beginning for continuous looping.
All environmental assets are platform-filtered to Windows/Linux. SoLoud 5.1.2
builds with `no_xiph_libs` because only PCM WAV decoding is needed.

Focus reuses ThemeLayerPaint, ColorScheme and the existing localization catalogs.
Timers, sessions, music, analytics, task timers and media-session integration are
deliberately outside v1; TODO.md records those future decisions.


## Focus v2 sessions

`FocusSessionController` is owned by bootstrap and exposed through an app-scoped
Riverpod provider. Only the session view and shell indicator listen to timer
updates. The controller uses injected monotonic time (Stopwatch in production)
and a one-second display heartbeat; it never decrements a seconds counter.
Wall timestamps provide history and detect suspension. Gaps over 15 seconds or
backwards wall-clock changes mark the session interrupted without counting the
gap. This deliberately also pauses on long application stalls.

Drift v5 adds only `focus_sessions`, with indexed start time and task reference.
Typed session/configuration snapshots carry UUIDs, state, phase, cycle count,
planned/actual duration, timestamps, optional task/label and soundscape snapshots.
Task references deliberately have no cascading foreign key. Start, pause, resume,
finish and interruption persist before publishing their transition. No per-second
writes occur. A crash can lose work measured since the last transition, but does
not count offline time; restoration always offers an interrupted session, never
automatically playing audio. Normal close checkpoints the timer. Failed recovery
blocks another start until recovery succeeds.

Simple setup defaults and last soundscape ID use existing SharedPreferences.
Session snapshots retain their Pomodoro configuration so a resumed cycle stays
consistent. Completed Focus blocks prepare short/long breaks, and breaks prepare
Focus. Each auto-start flag defaults off; cancelled blocks never advance a cycle.
All cancellations remain in history for predictable retention. History queries
show the most recent 100 entries without deleting older records.

The session controller reuses FocusPlayer, TaskRepository and the existing
notification adapter. Timer pause/finish/cancel never controls audio. Immediate
Linux notifications use the existing plugin's Linux adapter; scheduled task
reminders remain unsupported there. Notification failures cannot undo completion.
The optional Complete Task action stays available during an auto-started break.

Validation covers fake-clock transitions, suspension, recovery, task deletion,
file-backed history, v1–v4 migrations, task/setup/Quick Focus/navigation widgets on
Windows and Linux variants, and extreme/gradient themes with enlarged text.
The native desktop integration scenario also includes task sessions and restart.
The local Linux release build and native integration scenario pass with
`GDK_BACKEND=x11 LIBGL_ALWAYS_SOFTWARE=1`; Windows runtime validation remains in TODO.md. Physical notifications/audio/sleep behavior
require target-hardware checks.

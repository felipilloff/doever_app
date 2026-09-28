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

Environmental loops are original procedural sound designs, explicitly described
as synthesized ambience, not field recordings. Their reproducible generator and
license provenance ship with the repository. White, pink, brown and approximate
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

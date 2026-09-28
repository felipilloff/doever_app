# Focus audio provenance

All fourteen bundled ambient loops are **original procedural sound designs**
created for Doever, distributed under the repository's MIT license. They are
synthesized interpretations, not field recordings. No third-party audio,
sample library, voice recording, music, or extracted product asset is included.

Source/author: Doever project, [`tool/generate_focus_audio.py`](../../tool/generate_focus_audio.py).
The script is the complete reproducible source; no external source URL applies.
Each file is mono 44.1 kHz / 16-bit PCM, 24 seconds, peak-normalized to 0.65.
Modifications: synthesis, circular filtering/event wrapping, soft limiting,
DC removal and normalization as specified by that script.

| Asset (`ambience/`) | Synthesis | Seed |
|---|---|---|
| lightRain.wav | High-frequency rain bed and droplets | 20260927 |
| heavyRain.wav | Broad rain bed and dense droplets | 20260928 |
| thunder.wav | Slow, low-frequency rolling rumble | 20260929 |
| wind.wav | Filtered gusts | 20260930 |
| ocean.wav | Four broad wave envelopes | 20260931 |
| stream.wav | Water bed and descending bubbles | 20260932 |
| birds.wav | Two families of chirped tones | 20260933 |
| crickets.wav | Short high-frequency chirps | 20260934 |
| fireplace.wav | Low fire bed and crackles | 20260935 |
| vinyl.wav | Restrained hiss and short clicks | 20260936 |
| cafe.wav | Abstract room murmur and cup-like tones; no speech | 20260937 |
| train.wav | Low rolling bed and rhythmic wheel texture | 20260938 |
| keyboard.wav | Short key-like noise and pitched taps | 20260939 |
| office.wav | Quiet ventilation and distant key-like taps | 20260940 |

White, pink, brown and grey noise are generated locally by Doever's Dart noise
generator, also under MIT. Grey is a documented perceptual approximation, not a
claim to a uniquely defined spectrum. SoLoud and its dependencies retain their
own licenses in the application's license notices.

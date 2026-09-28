"""Prepare licensed Focus recordings without changing the playback engine.

Install numpy, scipy and soundfile in a development environment, then run:
  python tool/prepare_focus_recordings.py /path/to/downloaded-recordings

Input filenames are <asset>.mp3. Download URLs and SHA-256 hashes are recorded in
assets/audio/recordings.json. This tool never downloads or executes remote data.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import wave

import numpy as np
from scipy.signal import resample_poly
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
RATE = 44100
FRAMES = RATE * 24
FADE = RATE  # One-second overlap, without inserting silence at the seam.


def prepare(source, start_seconds):
    with sf.SoundFile(source) as recording:
        recording.seek(round(start_seconds * recording.samplerate))
        samples = recording.read(round(25 * recording.samplerate), always_2d=True)
        rate = recording.samplerate
    audio = samples.mean(axis=1)
    if len(audio) < rate * 3 or not np.isfinite(audio).all():
        raise ValueError(f'Invalid or too short recording: {source}')
    divisor = math.gcd(rate, RATE)
    audio = resample_poly(audio, RATE // divisor, rate // divisor)
    audio -= audio.mean()
    # Short recordings repeat with an overlap too, never a hard concatenation.
    ramp = np.linspace(0, 1, FADE)
    original = audio.copy()
    while len(audio) < FRAMES + FADE:
        overlap = audio[-FADE:] * (1 - ramp) + original[:FADE] * ramp
        audio = np.concatenate((audio[:-FADE], overlap, original[FADE:]))
    audio = audio[:FRAMES + FADE]
    # Rotate the boundary into a crossfade. Both joins preserve adjacent samples.
    overlap = audio[-FADE:] * (1 - ramp) + audio[:FADE] * ramp
    audio = np.concatenate((overlap, audio[FADE:FRAMES]))
    audio -= audio.mean()
    peak = np.max(np.abs(audio))
    if peak < 1e-6:
        raise ValueError(f'Silent recording: {source}')
    # Match the existing assets' soft limiting so isolated loud clicks do not
    # make the entire recording inaudibly quiet at existing mixer volumes.
    audio = np.tanh(audio / max(np.std(audio) * 3, .001))
    audio -= audio.mean()
    # Preserve the engine's .65 peak budget, including during crossfades.
    audio *= .65 / peak
    return np.rint(audio * 32767).astype('<i2')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source_directory', type=Path)
    args = parser.parse_args()
    entries = json.loads((ROOT / 'assets/audio/recordings.json').read_text())
    prepared = []
    for entry in entries:
        source = args.source_directory / (entry['asset'] + '.mp3')
        if hashlib.sha256(source.read_bytes()).hexdigest() != entry['sha256']:
            raise ValueError(f'Source checksum mismatch: {source}')
        pcm = prepare(source, entry['start_seconds'])
        assert len(pcm) == FRAMES
        steps = np.abs(np.diff(pcm.astype(np.int32)))
        assert abs(int(pcm[-1]) - int(pcm[0])) <= np.quantile(steps, .999) + 1, entry['asset']
        prepared.append((entry['asset'], pcm))
    # Validate every input before overwriting any bundled asset.
    for name, pcm in prepared:
        with wave.open(str(ROOT / 'assets/audio/ambience' / (name + '.wav')), 'wb') as out:
            out.setparams((1, 2, RATE, FRAMES, 'NONE', 'not compressed'))
            out.writeframes(pcm.tobytes())
        print(f'{name}: 24s, mono PCM16, peak .65')


if __name__ == '__main__':
    main()

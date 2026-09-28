"""Reproduce Doever's original synthetic vinyl texture. Requires NumPy.

Environmental recordings are prepared by prepare_focus_recordings.py instead.
Circular noise filters and wrapped event envelopes make every loop continuous.
Run from the repository root; outputs mono 44.1 kHz, signed 16-bit PCM WAV.
"""
from pathlib import Path
import wave
import numpy as np

RATE, SECONDS = 44100, 24
N = RATE * SECONDS
ROOT = Path(__file__).resolve().parents[1] / "assets/audio/ambience"
ROOT.mkdir(parents=True, exist_ok=True)


def render(name, seed):
    rng = np.random.default_rng(seed)

    def bed(low, high):
        frequencies = np.fft.rfftfreq(N, 1 / RATE)
        spectrum = np.fft.rfft(rng.normal(size=N))
        response = (1 - np.exp(-(frequencies / low) ** 2)) * np.exp(-(frequencies / high) ** 2)
        result = np.fft.irfft(spectrum * response, n=N)
        return result / max(np.std(result), .001)

    def events(count, duration, pitch=None, chirp=0):
        result = np.zeros(N)
        for _ in range(count):
            size = int(RATE * duration * rng.uniform(.7, 1.3))
            t = np.arange(size) / RATE
            envelope = np.sin(np.linspace(0, np.pi, size)) ** 2
            if pitch is None:
                signal = rng.normal(size=size) * np.exp(-t * 9 / duration)
            else:
                frequency = pitch * rng.uniform(.8, 1.2)
                signal = np.sin(2 * np.pi * (frequency * t + chirp * t * t))
            start = rng.integers(N)
            result[(start + np.arange(size)) % N] += signal * envelope * rng.uniform(.4, 1)
        return result

    if name == "vinyl":
        audio = .035 * bed(500, 9000) + events(160, .004) * 6
    else:
        raise ValueError(name)
    audio -= np.mean(audio)
    # Soft limiting keeps transients comfortable; hard peak bound supports the
    # player's conservative maximum-eight-track / two-bank crossfade gain.
    audio = np.tanh(audio / max(np.std(audio) * 3, .001))
    audio *= .65 / max(np.max(np.abs(audio)), .001)
    pcm = np.round(audio * 32767).astype('<i2')
    with wave.open(str(ROOT / f"{name}.wav"), 'wb') as out:
        out.setparams((1, 2, RATE, N, 'NONE', 'not compressed'))
        out.writeframes(pcm.tobytes())
    # A seam should behave like an ordinary adjacent sample, never a silence gap.
    seam = abs(float(audio[-1] - audio[0]))
    print(f"{name:12} peak={np.max(np.abs(audio)):.3f} rms={np.std(audio):.3f} seam={seam:.4f}")


if __name__ == '__main__':
    render('vinyl', 20260936)

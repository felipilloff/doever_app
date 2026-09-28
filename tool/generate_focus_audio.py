"""Reproduce Doever's original, synthetic ambient loops. Requires NumPy.

No recordings, downloaded samples, speech, or proprietary presets are used.
Circular noise filters and wrapped event envelopes make every loop continuous.
Run from the repository root; outputs mono 44.1 kHz, signed 16-bit PCM WAV.
"""
from pathlib import Path
import wave
import numpy as np

RATE, SECONDS = 44100, 24
N = RATE * SECONDS
TIME = np.arange(N) / RATE
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

    def swell(cycles, floor=.4):
        return floor + (1 - floor) * (.5 + .5 * np.sin(2 * np.pi * cycles * TIME / SECONDS))

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

    if name == "lightRain":
        audio = .25 * bed(700, 9500) + events(650, .02) * 4
    elif name == "heavyRain":
        audio = .4 * bed(200, 8500) * swell(3, .8) + events(1100, .03) * 2
    elif name == "thunder":
        audio = bed(22, 240) * (swell(3, .01) ** 5) + .07 * bed(400, 3500)
    elif name == "wind":
        audio = bed(90, 1700) * swell(3, .12) + .05 * bed(700, 6000)
    elif name == "ocean":
        audio = bed(120, 6500) * swell(4, .08) ** 2
    elif name == "stream":
        audio = .4 * bed(450, 8000) + events(160, .06, 900, -1200)
    elif name == "birds":
        audio = .025 * bed(250, 2500) + events(35, .24, 2500, 1600) + events(20, .13, 4200, -1800)
    elif name == "crickets":
        audio = .025 * bed(800, 8000) + events(135, .13, 4800, 80)
    elif name == "fireplace":
        audio = .18 * bed(100, 2200) * swell(5, .65) + events(140, .055) * 5
    elif name == "vinyl":
        audio = .035 * bed(500, 9000) + events(160, .004) * 6
    elif name == "cafe":
        # Abstract low room babble and cups; no recorded or intelligible voices.
        audio = .25 * bed(150, 900) * swell(7, .65) + .1 * bed(550, 1600) * swell(11)
        audio += events(25, .12, 1900) * .25 + events(60, .025) * .8
    elif name == "train":
        audio = .3 * bed(35, 750) + .15 * bed(800, 4500) * swell(48, .3)
    elif name == "keyboard":
        audio = events(210, .024) * 3 + events(180, .019, 310) * .5
    elif name == "office":
        audio = .12 * bed(120, 1500) + events(80, .025) * .4
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
    for index, sound in enumerate((
        'lightRain', 'heavyRain', 'thunder', 'wind', 'ocean', 'stream',
        'birds', 'crickets', 'fireplace', 'vinyl', 'cafe', 'train', 'keyboard', 'office',
    )):
        render(sound, 20260927 + index)

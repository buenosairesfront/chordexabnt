**English** · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# Chordex ABNT

A pad, ambient, lead and texture chord instrument for
[monome norns](https://monome.org/docs/norns/). One key plays a four-note
chord plus bass through a subtractive engine with 4 families × 8 presets —
32 sounds. Instead of an arpeggiator it has **MOTION**: the chord keeps
sounding and the sound itself keeps changing.

![Chordex ABNT](docs/sheet.png)

**The screen is the sound, computed with the same recipe that plays it:**

- **left:** the voice. A (three detuned saws), B, SUB and AIR are circles
  whose brightness is their level; they send particles into the filter. The
  dot inside the filter is the cutoff, the ring is the resonance, and the
  filter sways with the LFO. Below, the 10 faders.
- **center:** the flower — the real waveform of the note drawn in polar
  form. Ghost = detune, fuzz = air, gaps = grain, opening rings = echo,
  sparks = shimmer. Inside, the chord on a 12-note wheel.
- **right:** family and preset, oscilloscope, spectrum and the motion curve
  with a dot running along it.

## Features

- **4 families × 8 presets**
  - **PAD**: warm pad, glass pad, strings, choir, sweep pad, dark pad, brass
    pad, '80s poly
  - **AMBIENT**: long attacks, big hall, echo and shimmer
  - **LEAD**: monophonic with glide (last-note priority)
  - **TEXTURE**: grains, rain, static, sand, insects, ice, motor, mist
- **voice**: three detuned VarSaws (saw → triangle), a pulse oscillator at a
  chosen interval with PWM, sub, filtered breath noise (air), random grains,
  resonant filter with its own envelope and LFO, drive, glide
- **MOTION** (K2), tempo-synced, 6 modes:
  - **OLA** (wave): the filter sweeps up and down
  - **DERIVA** (drift): cutoff, shape, detune and oscillator B wander slowly at random
  - **RESPIRA** (breathe): each voice of the chord rises, falls and moves in the stereo
    field on its own
  - **PULSO** (pulse): rhythmic volume gate (echo and hall keep ringing)
  - **GIRO** (spin): the sound rotates in stereo and the chorus opens up
  - **MAREA** (tide): the volume swells and recedes; the hall grows as it falls
  Each family brings its own mode (PAD OLA, AMBIENT DERIVA, LEAD PULSO,
  TEXTURE RESPIRA)
- **effects**: chorus, tempo-synced ping-pong echo, shimmer, hall
- **10 chords**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4
- **strum** panel, **chord mode** on/off (off = up to 8 keys at once) and
  **hold**
- follows incoming MIDI clock for the motion and echo tempo
- all settings are saved automatically

<!-- u-ma:family -->
## The Chordex family

Same controls, different engines. Try the others:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80)**<br>'80s polysynth with an outrun sunset<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm)**<br>4-operator FM, drawn as a flower<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexstg"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexstg/main/docs/2_tutti.png" width="200" alt="ChordexSTG"></a> | **[ChordexSTG](https://github.com/buenosairesfront/chordexstg)**<br>orchestral strings with real bowed-string motion<br>`;install https://github.com/buenosairesfront/chordexstg` |
| <a href="https://github.com/buenosairesfront/chordexwt"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt)**<br>wavetable: 8 banks of 8 waves, drawn as a 3D table<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip)**<br>chiptune: 8 console chips × 8 presets, drawn as a tracker<br>`;install https://github.com/buenosairesfront/chordexchip` |

**More from U-MA:** every instrument and tool in one place → [U-MA showcase](https://github.com/buenosairesfront/U-ma)
<!-- /u-ma:family -->

## Requirements

- norns (shield, standard or fates)
- a MIDI keyboard or controller

## Install

From maiden:

```
;install https://github.com/buenosairesfront/chordexabnt
```

Then **restart norns** (SYSTEM > RESTART) so the new engine `ChordexABNT` is
compiled, and load **chordexabnt** from SELECT.

## Controls

| control | action |
|---|---|
| E1 | cutoff (brightness) |
| E2 | select fader |
| E3 | adjust fader |
| K3 + E1 | preset (all 32 in a row: PAD 1–8, AMBIENT, LEAD, TEXTURE) |
| K3 + E2 | hall |
| K3 + E3 | chord type |
| K3 held (without turning) | chord mode on/off |
| K2 (tap) | motion on/off |
| K2 + E1 | motion depth |
| K2 + E2 | motion mode |
| K2 + E3 | motion speed (1/16 to 16 bars) |
| K2 + K3 | opens the STRUM panel: E3 = time between the chord notes in beat divisions; + plays from the first note to the last, − from the last to the first |
| K1 held | hold on/off (diamond at the top right) |

**Faders:** attack, release, resonance, LFO movement, detune, air, grain,
echo, shimmer, glide.

**PARAMETERS menu:** MIDI channel (0 = all, the default), MIDI clock divider,
mono, shape, oscillator B and its interval, sub, octave, bass, decay,
sustain, filter envelope, LFO speed, drive, chorus, echo repeats and time,
volume, and everything above.

## Gallery

| | |
|---|---|
| ![PAD](docs/1_warm_pad.png) PAD · WARM PAD · maj7 · OLA | ![AMBIENT](docs/2_cristales.png) AMBIENT · CRISTALES · min7 · DERIVA |
| ![LEAD](docs/3_solo_saw.png) LEAD · SOLO SAW · glide | ![TEXTURE](docs/4_lluvia.png) TEXTURE · LLUVIA · RESPIRA |
| ![AMBIENT](docs/5_marea.png) AMBIENT · NUBE · m7b5 · MAREA | ![preset](docs/6_preset.png) choosing a preset (K3 + E1) |

## Credits

Made by [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA.
Released under the MIT license.

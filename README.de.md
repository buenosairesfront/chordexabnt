[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · **Deutsch** · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# Chordex ABNT

Ein Akkordinstrument für Pads, Ambient, Leads und Texturen auf
[monome norns](https://monome.org/docs/norns/). Eine Taste spielt einen
Vierklang plus Bass über eine subtraktive Engine mit 4 Familien × 8 Presets,
also 32 Klänge. Statt eines Arpeggiators gibt es **BEWEGUNG**: Der Akkord
klingt weiter, und der Klang selbst verändert sich.

![Chordex ABNT](docs/sheet.png)

**Der Bildschirm ist der Klang, berechnet nach demselben Rezept, das spielt:**

- **links:** die Stimme. A (drei verstimmte Sägezähne), B, SUB und AIRE
  (Luft) sind Kreise, deren Helligkeit ihr Pegel ist; sie schicken Partikel
  in den Filter. Der Punkt im Filter ist der Cutoff, der Ring die Resonanz,
  und der Filter schwankt mit dem LFO. Darunter die 10 Fader.
- **Mitte:** die Blume, die echte Wellenform der Note in Polarform. Geist =
  Verstimmung, Flaum = Luft, Lücken = Grain, sich öffnende Ringe = Echo,
  Funken = Shimmer. Innen der Akkord auf dem 12-Ton-Rad.
- **rechts:** Familie und Preset, Oszilloskop, Spektrum und die
  Bewegungskurve mit einem Punkt, der sie entlangläuft.

## Funktionen

- **4 Familien × 8 Presets**
  - **PAD**: Warm Pad, Glass Pad, Streicher, Chor, Sweep Pad, Dark Pad, Brass
    Pad, 80er-Poly
  - **AMBIENT**: lange Attacks, großer Hall, Echo und Shimmer
  - **LEAD**: monophon mit Glide (letzte Note hat Vorrang)
  - **TEXTURE**: Körner, Regen, Rauschen, Sand, Insekten, Eis, Motor, Nebel
- **Stimme**: drei verstimmte VarSaws (Sägezahn → Dreieck), ein
  Pulsoszillator in einem wählbaren Intervall mit PWM, Sub, gefiltertes
  Atemrauschen (Luft), zufällige Grains, Resonanzfilter mit eigener Hüllkurve
  und eigenem LFO, Drive, Glide
- **BEWEGUNG** (K2), tempo-synchron, 6 Modi:
  - **OLA** (Welle): der Filter fährt auf und ab
  - **DERIVA** (Drift): Cutoff, Form, Verstimmung und Oszillator B wandern
    langsam zufällig
  - **RESPIRA** (Atmen): jede Akkordstimme steigt, fällt und bewegt sich
    eigenständig im Stereobild
  - **PULSO** (Puls): rhythmisches Lautstärke-Gate (Echo und Hall klingen
    weiter)
  - **GIRO** (Drehung): der Klang kreist im Stereobild, der Chorus öffnet sich
  - **MAREA** (Gezeiten): die Lautstärke schwillt an und zieht sich zurück;
    der Hall wächst, wenn sie sinkt
  Jede Familie bringt ihren Modus mit (PAD OLA, AMBIENT DERIVA, LEAD PULSO,
  TEXTURE RESPIRA)
- **Effekte**: Chorus, tempo-synchrones Ping-Pong-Echo, Shimmer, Hall
- **10 Akkorde**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4
- **Strum**-Panel, **Akkordmodus** an/aus (aus = bis zu 8 Tasten
  gleichzeitig) und **Halten**
- folgt eingehender MIDI-Clock für das Tempo von Bewegung und Echo
- alle Einstellungen werden automatisch gespeichert

<!-- u-ma:family -->
## Die Chordex-Familie

Gleiche Bedienung, andere Engines. Probier die anderen aus:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.de.md)**<br>80er-Polysynth mit Outrun-Sonnenuntergang<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.de.md)**<br>FM mit 4 Operatoren, als Blume gezeichnet<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexstg/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexstg/main/docs/2_tutti.png" width="200" alt="ChordexSTG"></a> | **[ChordexSTG](https://github.com/buenosairesfront/chordexstg/blob/main/README.de.md)**<br>Orchesterstreicher mit echter Bewegung einer gestrichenen Saite<br>`;install https://github.com/buenosairesfront/chordexstg` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.de.md)**<br>Wavetable: 8 Bänke mit je 8 Wellen, als 3D-Tabelle gezeichnet<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.de.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.de.md)**<br>Chiptune: 8 Konsolenchips × 8 Presets, als Tracker gezeichnet<br>`;install https://github.com/buenosairesfront/chordexchip` |

**Mehr von U-MA:** alle Instrumente und Werkzeuge an einem Ort → [U-MA-Übersicht](https://github.com/buenosairesfront/U-ma/blob/main/README.de.md)
<!-- /u-ma:family -->

## Voraussetzungen

- norns (Shield, Standard oder Fates)
- ein MIDI-Keyboard oder -Controller

## Installation

In maiden:

```
;install https://github.com/buenosairesfront/chordexabnt
```

Danach **norns neu starten** (SYSTEM > RESTART), damit die neue Engine
`ChordexABNT` kompiliert wird, und **chordexabnt** unter SELECT laden.

## Bedienung

| Bedienelement | Funktion |
|---|---|
| E1 | Cutoff (Helligkeit) |
| E2 | Fader wählen |
| E3 | Fader einstellen |
| K3 + E1 | Preset (alle 32 hintereinander: PAD 1–8, AMBIENT, LEAD, TEXTURE) |
| K3 + E2 | Hall |
| K3 + E3 | Akkordtyp |
| K3 halten (ohne Drehen) | Akkordmodus an/aus |
| K2 (tippen) | Bewegung an/aus |
| K2 + E1 | Tiefe der Bewegung |
| K2 + E2 | Modus der Bewegung |
| K2 + E3 | Geschwindigkeit der Bewegung (1/16 bis 16 Takte) |
| K2 + K3 | öffnet das STRUM-Panel: E3 = Zeit zwischen den Akkordtönen in Schlagunterteilungen; + spielt von der ersten zur letzten Note, − von der letzten zur ersten |
| K1 halten | Halten an/aus (Raute oben rechts) |

**Fader:** Attack, Release, Resonanz, LFO-Bewegung, Verstimmung, Luft,
Grain, Echo, Shimmer, Glide.

**Menü PARAMETERS:** MIDI-Kanal (Standard 1; 0 = alle), MIDI-Clock-Teiler,
Mono, Form, Oszillator B und sein Intervall, Sub, Oktave, Bass, Decay,
Sustain, Filterhüllkurve, LFO-Geschwindigkeit, Drive, Chorus,
Echo-Wiederholungen und -Zeit, Lautstärke und alles oben Genannte.

## arc und crow

Beide sind optional: ohne angeschlossenes arc oder crow ändert sich nichts.

**arc** (4 Ringe, als Drehregler dargestellt): 1 Cutoff · 2 Bewegungstiefe · 3 Bewegungstempo · 4 Hall

**crow**: IN1 = Tonhöhe (V/Okt., 0 V = C4), IN2 = Gate (spielt und lässt los) · OUT1 = Grundton des Akkords (V/Okt.) · OUT2 = Hüllkurve (0–8 V, mit Attack und Release des Klangs) · OUT3 = die Bewegung als LFO (wenn sie an ist) · OUT4 = ein Puls bei jedem Akkord. Abschaltbar unter PARAMETERS > ARC / CROW.

**Tempo:** beim ersten Start ist das interne Tempo 50 BPM. Eingehende MIDI-Clock (an jedem MIDI-Port) bestimmt das Tempo, sobald sie anliegt.

## Galerie

| | |
|---|---|
| ![PAD](docs/1_warm_pad.png) PAD · WARM PAD · maj7 · OLA | ![AMBIENT](docs/2_cristales.png) AMBIENT · CRISTALES · min7 · DERIVA |
| ![LEAD](docs/3_solo_saw.png) LEAD · SOLO SAW · Glide | ![TEXTURE](docs/4_lluvia.png) TEXTURE · LLUVIA · RESPIRA |
| ![AMBIENT](docs/5_marea.png) AMBIENT · NUBE · m7b5 · MAREA | ![preset](docs/6_preset.png) Preset-Wahl (K3 + E1) |

## Credits

Gemacht von [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA.
Veröffentlicht unter der MIT-Lizenz.

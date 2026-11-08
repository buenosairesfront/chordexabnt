[English](README.md) · **Español** · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# Chordex ABNT

Instrumento de acordes para pads, ambient, leads y texturas en
[monome norns](https://monome.org/docs/norns/). Una tecla toca un acorde de
cuatro notas más el bajo a través de un motor sustractivo con 4 familias ×
8 presets, 32 sonidos. En lugar de arpegiador tiene **MOVIMIENTO**: el
acorde queda sostenido y lo que cambia es el sonido.

![Chordex ABNT](docs/sheet.png)

**La pantalla es el sonido, calculado con la misma receta que suena:**

- **izquierda:** la voz. A (tres sierras desafinadas), B, SUB y AIRE son
  círculos que brillan según su nivel y mandan partículas al filtro. El punto
  adentro del filtro es el cutoff, el anillo es la resonancia, y el filtro se
  mece con el LFO. Abajo, los 10 faders.
- **centro:** la flor, la onda real de la nota dibujada en polar. Fantasma =
  desafinación, pelusa = aire, cortes = grano, anillos que se abren = eco,
  chispas = shimmer. Adentro, el acorde en la rueda de 12 notas.
- **derecha:** familia y preset, osciloscopio, espectro y la curva del
  movimiento con un punto que la recorre.

## Características

- **4 familias × 8 presets**
  - **PAD**: warm pad, glass pad, cuerdas, coro, sweep pad, dark pad, brass
    pad, poli ochentoso
  - **AMBIENT**: ataques largos, hall grande, eco y shimmer
  - **LEAD**: monofónico con glide (manda la última nota)
  - **TEXTURE**: granos, lluvia, estática, arena, insectos, hielo, motor,
    bruma
- **voz**: tres VarSaw desafinadas (sierra → triángulo), un oscilador de
  pulso a un intervalo con PWM, sub, ruido de soplido filtrado (aire), granos
  al azar, filtro resonante con envolvente y LFO propios, drive, glide
- **MOVIMIENTO** (K2), a tempo, 6 modos:
  - **OLA**: el filtro sube y baja
  - **DERIVA**: cutoff, forma, desafinación y osc B se van al azar, lento
  - **RESPIRA**: cada voz del acorde sube, baja y se mueve en estéreo por su
    cuenta
  - **PULSO**: gate rítmico del volumen (el eco y el hall siguen sonando)
  - **GIRO**: el sonido gira en estéreo y el chorus se abre
  - **MAREA**: el volumen crece y se retira; el hall se agranda cuando baja
  Cada familia trae su modo (PAD OLA, AMBIENT DERIVA, LEAD PULSO,
  TEXTURE RESPIRA)
- **efectos**: chorus, eco ping-pong a tempo, shimmer, hall
- **10 acordes**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4
- panel de **strum**, **modo acorde** on/off (off = hasta 8 teclas juntas) y
  **retener**
- sigue el reloj MIDI entrante para el tempo del movimiento y del eco
- todo se guarda solo

<!-- u-ma:family -->
## La familia Chordex

Mismos controles, motores distintos. Probá los otros:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.es.md)**<br>polisynth ochentoso con atardecer outrun<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.es.md)**<br>FM de 4 operadores, dibujado como una flor<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexstg/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexstg/main/docs/2_tutti.png" width="200" alt="ChordexSTG"></a> | **[ChordexSTG](https://github.com/buenosairesfront/chordexstg/blob/main/README.es.md)**<br>cuerdas de orquesta con el movimiento real de una cuerda frotada<br>`;install https://github.com/buenosairesfront/chordexstg` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.es.md)**<br>wavetable: 8 bancos de 8 ondas, dibujado como una tabla en 3D<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.es.md)**<br>chiptune: 8 chips de consola × 8 presets, dibujado como un tracker<br>`;install https://github.com/buenosairesfront/chordexchip` |

**Más de U-MA:** todos los instrumentos y herramientas en un solo lugar → [muestrario U-MA](https://github.com/buenosairesfront/U-ma/blob/main/README.es.md)
<!-- /u-ma:family -->

## Requisitos

- norns (shield, standard o fates)
- un teclado o controlador MIDI

## Instalación

Desde maiden:

```
;install https://github.com/buenosairesfront/chordexabnt
```

Después **reiniciá la norns** (SYSTEM > RESTART) para que se compile el engine
nuevo `ChordexABNT`, y cargá **chordexabnt** desde SELECT.

## Controles

| control | acción |
|---|---|
| E1 | cutoff (brillo) |
| E2 | elige fader |
| E3 | ajusta fader |
| K3 + E1 | preset (los 32 en fila: PAD 1–8, AMBIENT, LEAD, TEXTURE) |
| K3 + E2 | hall |
| K3 + E3 | tipo de acorde |
| K3 mantenido (sin girar) | modo acorde on/off |
| K2 (toque) | movimiento on/off |
| K2 + E1 | profundidad del movimiento |
| K2 + E2 | modo del movimiento |
| K2 + E3 | velocidad del movimiento (1/16 a 16 compases) |
| K2 + K3 | abre el panel STRUM: E3 = tiempo entre las notas del acorde en divisiones del pulso; + toca de la primera nota a la última, − de la última a la primera |
| K1 mantenido | retener on/off (rombo arriba a la derecha) |

**Faders:** ataque, release, resonancia, movimiento del LFO, desafinación,
aire, grano, eco, shimmer, glide.

**Menú PARAMETERS:** canal MIDI (0 = todos, por defecto), divisor del reloj
MIDI, mono, forma, oscilador B y su intervalo, sub, octava, bajo, decay,
sustain, envolvente del filtro, velocidad del LFO, distorsión, chorus,
repeticiones y tiempo del eco, volumen, y todo lo anterior.

## Galería

| | |
|---|---|
| ![PAD](docs/1_warm_pad.png) PAD · WARM PAD · maj7 · OLA | ![AMBIENT](docs/2_cristales.png) AMBIENT · CRISTALES · min7 · DERIVA |
| ![LEAD](docs/3_solo_saw.png) LEAD · SOLO SAW · glide | ![TEXTURE](docs/4_lluvia.png) TEXTURE · LLUVIA · RESPIRA |
| ![AMBIENT](docs/5_marea.png) AMBIENT · NUBE · m7b5 · MAREA | ![preset](docs/6_preset.png) eligiendo preset (K3 + E1) |

## Créditos

Hecho por [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA.
Publicado con licencia MIT.

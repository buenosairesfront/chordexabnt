-- Chordex ABNT
-- hermano sustractivo de Chordex80 / ChordexFM / ChordexWT / ChordexCHIP:
-- mismo instrumento de acordes (una tecla = un acorde de 4 tonos + bajo,
-- retener, strum) con un motor para PADS, AMBIENT, LEADS y
-- TEXTURAS: 4 familias x 8 presets.
--
-- La pantalla (como Chordex FM, calculada con la misma receta que suena):
--   izquierda: la voz. A (3 sierras desafinadas), B, SUB y AIRE (círculos,
--     brillo = nivel) mandan partículas al filtro; el punto adentro del
--     filtro es el cutoff, el anillo la resonancia, y se mece con el LFO.
--     Abajo, los 10 faders.
--   centro: la flor. La onda real de la nota en polar: fantasma =
--     desafinación, pelusa = aire, cortes = grano, anillos que se abren =
--     eco, chispas = shimmer; adentro el acorde en la rueda de 12 notas.
--   derecha: familia y preset, osciloscopio, espectro y la curva del
--     movimiento con un punto que la recorre.
--
-- Controles (los mismos de Chordex FM):
--   E1: cutoff (brillo)           K3 + E1: preset (los 32 en fila: PAD 1-8,
--                                          AMBIENT, LEAD, TEXTURE)
--   E2: elige fader               K3 + E2: hall (espacio)
--   E3: ajusta fader              K3 + E3: tipo de acorde
--   faders: ataque, release, resonancia, movimiento (LFO), desafinación,
--           aire, grano, eco, shimmer, glide
--   K2: tap = MOVIMIENTO on/off (el acorde queda sostenido, cambia el sonido)
--   K2 + E1: profundidad          K2 + E2: modo
--   K2 + E3: velocidad (a tempo, del reloj MIDI si entra)
--   modos: OLA (barrido del filtro), DERIVA (el timbre se va al azar),
--          RESPIRA (cada voz sube, baja y se mueve en estéreo), PULSO (gate
--          rítmico), GIRO (gira en estéreo), MAREA (el volumen crece y se
--          retira, el hall se agranda cuando baja)
--   K2 + K3: panel de strum (E3 = división, +/- = sentido)
--   K3 mantenido (sin girar nada): modo acorde on/off (off = una sola nota)
--   K1 mantenido: retener on/off (rombo arriba a la derecha)
--   LEAD es monofónico con glide (param "mono"; se puede cambiar en el menú)
--   clock MIDI entrante: marca el tempo del movimiento y del eco

engine.name = 'ChordexABNT'

local musicutil = require 'musicutil'

local midi_in
local current_note = nil
local current_vel = 0.8
local last_note = nil
local held_stack = {}
-- teclas que arpegia el modo simple (quedan con HOLD hasta la próxima tecla)
local arp_keys = {}
local function update_arp_keys()
  if #held_stack == 0 then return end
  arp_keys = {}
  for i, n in ipairs(held_stack) do arp_keys[i] = n end
  table.sort(arp_keys)
end
-- modo simple: qué teclas están sonando, para no redisparar si no cambió nada
local voiced_sig = nil
local function keys_sig() return table.concat(arp_keys, ",") end
local last_midi_clock = nil
local CLOCK_TIMEOUT = 0.5
local tick_sec = nil
local hold_on = false
local loading = false

local chord_types = {"maj", "min", "dim", "aug", "7", "maj7", "min7", "m7b5", "sus2", "sus4"}
local chord_suffix = {maj = "", min = "m", dim = "dim", aug = "+", ["7"] = "7",
  maj7 = "maj7", min7 = "m7", m7b5 = "m7b5", sus2 = "sus2", sus4 = "sus4"}
local chord_intervals = {
  maj = {0, 4, 7}, min = {0, 3, 7}, dim = {0, 3, 6}, aug = {0, 4, 8},
  ["7"] = {0, 4, 7, 10}, maj7 = {0, 4, 7, 11}, min7 = {0, 3, 7, 10},
  m7b5 = {0, 3, 6, 10}, sus2 = {0, 2, 7}, sus4 = {0, 5, 7},
}
local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
-- movimiento: modos y velocidades (en negras por ciclo)
local MOT_NAMES = {"OLA", "DERIVA", "RESPIRA", "PULSO", "GIRO", "MAREA"}
local MOT_DIV = {0.25, 0.5, 1, 2, 4, 8, 16, 32, 64}
local MOT_DIV_NAMES = {"1/16", "1/8", "1/4", "1/2", "1c", "2c", "4c", "8c", "16c"}
local MOT_DEF_DIV = {7, 6, 5, 2, 5, 6}   -- velocidad que trae cada modo
local strum_div_names = {"1/64", "1/32", "1/16T", "1/16", "1/8T", "1/8", "1/4"}
local strum_div_beats = {1 / 16, 1 / 8, 1 / 6, 1 / 4, 1 / 3, 1 / 2, 1}
local function strum_text(v)
  if v == 0 then return "OFF" end
  return (v > 0 and "+" or "-") .. strum_div_names[math.abs(v)]
end
-- intervalo del oscilador B (relación de frecuencia)
local INT2 = {0.5, 1, 1.5, 2, 3, 4}
local INT2_NAMES = {"-8va", "unisono", "+5a", "+8va", "+8va+5a", "+2 8vas"}
-- tiempo del eco en negras
local ECO_DIV = {0.5, 0.75, 1, 1.5, 2}
local ECO_NAMES = {"1/8", "1/8.", "1/4", "1/4.", "1/2"}

-- ============================================================
-- familias y presets
-- ============================================================
-- a ataque, d decay, s sustain, r release, fo forma (0 sierra .. 0.5 triángulo),
-- o2 osc B, i2 intervalo de B (índice de INT2), sb sub, dt desafinación,
-- ai aire, gr grano, c cutoff, q reso, fe env del filtro, mv movimiento,
-- mr velocidad del LFO (Hz), dr drive, gl glide, bs bajo, ch chorus,
-- e eco, ef realimentación del eco, et tiempo del eco (índice de ECO_DIV),
-- sh shimmer, h hall, o octava, mm modo de movimiento, md profundidad

local DEF = {a = 0.4, d = 1.2, s = 0.8, r = 2, fo = 0.1, o2 = 0.3, i2 = 4, sb = 0.2,
  dt = 0.4, ai = 0.05, gr = 0, c = 0.55, q = 0.2, fe = 0.2, mv = 0.25, mr = 0.2,
  dr = 0.05, gl = 0, bs = 0.4, ch = 0.4, e = 0, ef = 0.5, et = 2, sh = 0, h = 0.3, o = 0,
  mm = 1, md = 0.5}

local FAMS = {
  {name = "PAD", def = {mm = 1, md = 0.5}, presets = {
    -- guardado desde la norns (2026-11-07): con aire, grano, eco y shimmer
    {n = "WARM PAD",   a = 0.6, d = 2, s = 0.85, r = 2.5, fo = 0.05, o2 = 0.25, dt = 0.45, c = 0.55, q = 0.15, fe = 0.15, ch = 0.5,
     ai = 0.31, gr = 0.46, gl = 0.01, e = 0.58, sh = 0.58},
    {n = "GLASS PAD",  fo = 0.5, o2 = 0.35, i2 = 6, dt = 0.3, c = 0.7, q = 0.3, sh = 0.35, h = 0.4},
    {n = "STRINGS",    a = 0.35, fo = 0, o2 = 0, sb = 0.1, dt = 0.7, c = 0.6, mv = 0.15, ch = 0.6},
    {n = "CHOIR",      fo = 0.35, ai = 0.25, c = 0.45, q = 0.45, fe = 0, mv = 0.3, mr = 0.3},
    {n = "SWEEP PAD",  a = 1.2, d = 3.5, c = 0.3, q = 0.55, fe = 0.6, mv = 0.5, mr = 0.08},
    {n = "DARK PAD",   c = 0.3, sb = 0.5, dt = 0.5, o2 = 0.3, i2 = 1, q = 0.1},
    {n = "BRASS PAD",  a = 0.15, d = 0.8, s = 0.7, r = 1.2, fo = 0, c = 0.4, fe = 0.5, dt = 0.35},
    {n = "80s POLY",   a = 0.02, d = 0.8, s = 0.6, r = 0.8, fo = 0, o2 = 0.5, i2 = 2, dt = 0.5, c = 0.5, fe = 0.4, ch = 0.7, e = 0.2},
  }},
  {name = "AMBIENT", def = {mm = 2, md = 0.6, a = 2, r = 5, h = 0.55, e = 0.3, ef = 0.6, et = 4, sh = 0.3, mr = 0.08}, presets = {
    {n = "NUBE",       a = 2.5, fo = 0.4, dt = 0.5, ai = 0.15, c = 0.45, mv = 0.4, sh = 0.4},
    {n = "HORIZONTE",  a = 3, fo = 0.5, o2 = 0.2, i2 = 5, sh = 0.6, h = 0.6},
    {n = "DRONE",      a = 1.5, s = 1, sb = 0.6, o2 = 0.4, i2 = 3, dt = 0.25, c = 0.35, mv = 0.6, mr = 0.03, e = 0.15},
    {n = "VIENTO",     ai = 0.8, o2 = 0, sb = 0, c = 0.5, q = 0.6, mv = 0.7, mr = 0.12, sh = 0.1},
    {n = "ECO SUAVE",  a = 0.05, d = 1.5, s = 0.3, r = 3, fo = 0.5, e = 0.6, ef = 0.7, et = 2, sh = 0.1},
    {n = "CRISTALES",  a = 0.01, d = 2, s = 0, r = 4, fo = 0.5, o2 = 0.4, i2 = 6, c = 0.8, sh = 0.7, e = 0.4},
    {n = "SUBMARINO",  c = 0.2, q = 0.5, sb = 0.5, mv = 0.5, mr = 0.05, e = 0.4, h = 0.6, dt = 0.6, sh = 0},
    {n = "AURORA",     fo = 0.2, dt = 0.8, sh = 0.5, mv = 0.4, mr = 0.1, ch = 0.8, e = 0.25},
  }},
  {name = "LEAD", mono = true, def = {mm = 4, md = 0.7, a = 0.01, d = 0.6, s = 0.8, r = 0.3, gl = 0.08, bs = 0,
      h = 0.2, ch = 0.2, dt = 0.2, mv = 0.1, mr = 5, e = 0.25, et = 2}, presets = {
    {n = "SOLO SAW",   fo = 0, o2 = 0.3, i2 = 2, dt = 0.25, c = 0.6, q = 0.3, fe = 0.4},
    {n = "SQUARE",     fo = 0.5, o2 = 0.8, i2 = 2, c = 0.55, gl = 0.06},
    {n = "ACID",       fo = 0, o2 = 0, c = 0.3, q = 0.75, fe = 0.8, d = 0.3, s = 0.4, dr = 0.4, gl = 0.1, o = -1},
    {n = "FLAUTA",     fo = 0.5, ai = 0.35, o2 = 0, sb = 0, c = 0.5, q = 0, fe = 0.1, mv = 0.4, gl = 0.05, h = 0.3},
    {n = "GRITO",      fo = 0, dr = 0.7, c = 0.65, q = 0.4, o2 = 0.5, i2 = 4, gl = 0.12},
    {n = "LASER",      fo = 0, fe = 1, c = 0.25, q = 0.7, d = 0.4, s = 0.5, gl = 0.2, e = 0.4},
    {n = "SUAVE",      fo = 0.4, sb = 0.4, o2 = 0.1, c = 0.4, gl = 0.15, h = 0.35, e = 0.35},
    {n = "QUINTAS",    fo = 0, o2 = 0.6, i2 = 3, dt = 0.3, c = 0.55, gl = 0.07, ch = 0.4},
  }},
  {name = "TEXTURE", def = {mm = 3, md = 0.6, gr = 0.5, a = 0.3, r = 2.5, h = 0.45, fo = 0.5, e = 0.2, et = 3}, presets = {
    {n = "GRANOS",     gr = 0.6, e = 0.3},
    {n = "LLUVIA",     gr = 0.9, ai = 0.3, c = 0.7, sh = 0.3, h = 0.5},
    {n = "ESTATICA",   ai = 0.6, gr = 0.5, q = 0.5, c = 0.5, h = 0.3},
    {n = "ARENA",      gr = 0.4, ai = 0.5, mv = 0.5, mr = 0.2, c = 0.45},
    {n = "INSECTOS",   gr = 0.75, o2 = 0.6, i2 = 6, q = 0.6, c = 0.6, mv = 0.6, mr = 0.7},
    {n = "HIELO",      gr = 0.3, o2 = 0.5, i2 = 6, sh = 0.8, h = 0.6},
    {n = "MOTOR",      gr = 0.95, fo = 0.1, sb = 0.6, c = 0.3, dr = 0.4, h = 0.2},
    {n = "BRUMA",      ai = 0.9, gr = 0.2, c = 0.35, q = 0.3, h = 0.6, e = 0.4, mv = 0.5, mr = 0.07},
  }},
}
local fam_names = {}
for i, f in ipairs(FAMS) do
  fam_names[i] = f.name
  for _, p in ipairs(f.presets) do
    for k, v in pairs(f.def) do if p[k] == nil then p[k] = v end end
    for k, v in pairs(DEF) do if p[k] == nil then p[k] = v end end
  end
end

-- faders (E2 elige, E3 ajusta); el cutoff va en E1, como el índice del FM
local P = {
  {id = "atk",     min = 0.001, max = 6,   step = 0.02},
  {id = "rel",     min = 0.02,  max = 10,  step = 0.05},
  {id = "res",     min = 0,     max = 1,   step = 0.02},
  {id = "mov",     min = 0,     max = 1,   step = 0.02},
  {id = "det",     min = 0,     max = 1,   step = 0.02},
  {id = "aire",    min = 0,     max = 1,   step = 0.02},
  {id = "grano",   min = 0,     max = 1,   step = 0.02},
  {id = "eco",     min = 0,     max = 1,   step = 0.02},
  {id = "shimmer", min = 0,     max = 1,   step = 0.02},
  {id = "glide",   min = 0,     max = 1,   step = 0.01},
}
local focus_index = 1

local mot_flash = 0      -- cartel del movimiento (K2 + E2 / E3)
local k2_held, k2_turned, k3_held = false, false, false
local k3_turned = false
local k3_press = nil
local K3_LONG = 0.5   -- segundos manteniendo K3 para alternar el modo acorde

-- animación
local PULSE = 24
local pulse = {}          -- pulso por nombre de control
local flash = 0
local chord_flash = 0
local model_flash = 0
local hold_flash = 0
local strum_ui = false    -- panel de strum abierto (K2+K3)
local strum_t = 0         -- último movimiento en el panel
local STRUM_CLOSE = 3     -- segundos sin tocar E3 para cerrarlo
local strum_gen = 0
local last_t = nil

-- voces "simuladas" para que la pantalla respire igual que el sonido
local VS = {chord = nil}
local scene_hit   -- forward: la escena reacciona a cada nota

local function pv(id) return params:get(id) end
local function bump(name) pulse[name] = PULSE end
local function cur_fam() return FAMS[pv("fam")] end
local function cur_preset() return cur_fam().presets[pv("preset")] end
local function shift(n) return n + 12 * pv("oct") end
local function note_to_hz(n) return musicutil.note_num_to_freq(n) end
local function is_mono() return pv("mono") == 2 end
-- modo simple = modo acorde apagado y polifónico (suenan todas las teclas)
local function simple_mode() return pv("chord_on") == 1 and not is_mono() end

local function four_tone_intervals(name)
  -- modo acorde apagado o mono: suena solo la nota tocada
  if params:get("chord_on") == 1 or is_mono() then return {0} end
  local iv = chord_intervals[name]
  if #iv >= 4 then return iv end
  return {iv[1], iv[2], iv[3], iv[1] + 12}
end

local function chord_name() return chord_types[pv("chord")] end

-- ============================================================
-- sonido
-- ============================================================

local MAX_KEYS = 8

local function chord_tone_notes(note)
  local t = {}
  for _, iv in ipairs(four_tone_intervals(chord_name())) do t[#t + 1] = shift(note + iv) end
  -- modo simple con varias teclas: suenan todas juntas (hasta MAX_KEYS,
  -- las más agudas)
  if simple_mode() and #arp_keys > 1 then
    t = {}
    for i = math.max(1, #arp_keys - MAX_KEYS + 1), #arp_keys do t[#t + 1] = shift(arp_keys[i]) end
  end
  return t
end

-- forward: definida más abajo (depende del reloj MIDI)
local strum_step

local function strum_notes(t, n)
  -- solo las notas del acorde: + de la primera a la última, - al revés
  local out = {}
  if n > 0 then
    for i = 1, #t do out[i] = t[i] end
  else
    for i = #t, 1, -1 do out[#out + 1] = t[i] end
  end
  return out
end

local function sound_strum(note, t)
  local sn = strum_notes(t, pv("strum"))
  local n = #sn
  local step = strum_step()
  voiced_sig = keys_sig()
  engine.strumOn(note_to_hz(note - 24), current_vel)
  for i, m in ipairs(sn) do
    local pan = n > 1 and ((i - 1) / (n - 1) * 2 - 1) * 0.7 or 0
    if pv("strum") < 0 then pan = -pan end   -- cada nota queda en su lugar del panorama
    engine.strumNote(note_to_hz(m), (i - 1) * step, n, pan)
  end
  VS.chord = {t0 = util.time(), note = sn[1], vel = current_vel, notes = t}
  strum_gen = strum_gen + 1
  local g = strum_gen
  clock.run(function()
    for i, m in ipairs(sn) do
      if strum_gen ~= g or current_note == nil then return end
      scene_hit(m, current_vel)
      if i < n then clock.sleep(step) end
    end
  end)
  flash = 1
end

local function sound_chord(note)
  local t = chord_tone_notes(note)
  if pv("strum") ~= 0 and #t > 1 then return sound_strum(note, t) end
  if #t > 4 then
    -- más de 4 teclas: cada una con su voz (noteOn lleva solo 4)
    local n = #t
    voiced_sig = keys_sig()
    engine.strumOn(note_to_hz(note - 24), current_vel)
    for i, m in ipairs(t) do
      engine.strumNote(note_to_hz(m), 0, n, ((i - 1) / (n - 1) * 2 - 1) * 0.6)
    end
  else
    local f = {}
    for i = 1, 4 do f[i] = t[i] and note_to_hz(t[i]) or 0 end
    voiced_sig = keys_sig()
    engine.noteOn(f[1], f[2], f[3], f[4], note_to_hz(note - 24), current_vel)
  end
  -- mono con glide: la voz no se redispara, la pantalla tampoco
  local glided = is_mono() and pv("glide") > 0.001 and VS.chord and not VS.chord.t1
  if glided then
    VS.chord.note = t[1]; VS.chord.notes = t
  else
    VS.chord = {t0 = util.time(), note = t[1], vel = current_vel, notes = t}
  end
  for _, m in ipairs(t) do scene_hit(m, current_vel) end
  flash = 1
end

local function release_chord_vs()
  if VS.chord and not VS.chord.t1 then VS.chord.t1 = util.time() end
end

local function ext_clock_on()
  return last_midi_clock ~= nil and (util.time() - last_midi_clock) < CLOCK_TIMEOUT
end

local function beat_seconds()
  if ext_clock_on() and tick_sec then return tick_sec * 24 end
  return clock.get_beat_sec()
end

-- múltiplos del pulso: del reloj MIDI si entra, si no del tempo de la norns
strum_step = function()
  local v = math.abs(pv("strum"))
  if v == 0 then return 0 end
  return beat_seconds() * strum_div_beats[v]
end

-- con clock MIDI, algunos equipos repiten la nota apretada a tempo: el
-- soltar espera un poco y si vuelve la misma nota no se redispara
local release_id = nil

local function cancel_release()
  if release_id then clock.cancel(release_id); release_id = nil end
end

local function release_now()
  release_id = nil
  if #held_stack == 0 and not hold_on and current_note ~= nil then
    engine.noteOff(); release_chord_vs()
    current_note = nil
  end
end

local function release_grace()
  return util.clamp((tick_sec or 0.02) * 13, 0.05, 0.8)
end

local function on_note_on(note, vel)
  cancel_release()
  local prev = current_note
  local fresh = hold_on and #held_stack == 0 and prev ~= nil
  local added = hold_on and #held_stack > 0
  table.insert(held_stack, note)
  if added then
    -- con HOLD, una tecla más mientras hay otras apretadas se suma a lo
    -- retenido (aunque alguna ya se haya soltado)
    local dup = false
    for _, n in ipairs(arp_keys) do if n == note then dup = true end end
    if not dup then table.insert(arp_keys, note); table.sort(arp_keys) end
  else
    update_arp_keys()
  end
  -- modo acorde (y mono): manda la última tecla apretada;
  -- modo simple: suenan todas las apretadas y la más grave da el bajo
  local simple = simple_mode()
  local low = simple and arp_keys[1] or note
  if low ~= prev or fresh or (simple and keys_sig() ~= voiced_sig) then
    current_note = low
    last_note = low
    current_vel = vel / 127
    sound_chord(current_note)
  end
end

local function on_note_off(note)
  for i = #held_stack, 1, -1 do
    if held_stack[i] == note then table.remove(held_stack, i); break end
  end
  -- con HOLD, soltar teclas no cambia nada: queda el acorde / las notas
  -- tal como se apretaron
  if hold_on then return end
  update_arp_keys()
  -- modo acorde / mono: al soltar la que suena vuelve la última que sigue
  -- apretada; modo simple: soltar una de varias no redispara
  local low = held_stack[#held_stack]
  if simple_mode() then low = (low ~= nil) and current_note or nil end
  if low == nil then
    if not hold_on and current_note ~= nil then
      if ext_clock_on() then
        cancel_release()
        local wait = release_grace()
        release_id = clock.run(function() clock.sleep(wait); release_now() end)
      else
        release_now()
      end
    end
  elseif low ~= current_note then
    current_note = low
    last_note = low
    sound_chord(current_note)
  end
end

local function set_hold(on)
  hold_on = on
  hold_flash = PULSE
  if not on then cancel_release(); release_now() end
end

-- teclas soltadas con clock corriendo que esperan por si el equipo las repite
local repeat_off = {}
local function midi_event(data)
  local msg = midi.to_msg(data)
  if msg.type == "clock" then
    local now = util.time()
    if last_midi_clock then
      local d = now - last_midi_clock
      if d > 0.002 and d < 0.25 then
        tick_sec = tick_sec and (tick_sec * 0.9 + d * 0.1) or d
      end
    end
    last_midi_clock = now
    return
  elseif msg.type == "start" or msg.type == "stop" or msg.type == "continue" then
    return
  end
  local ch = params:get("midi_channel")
  if ch ~= 0 and msg.ch ~= ch then return end
  if msg.type == "note_on" and msg.vel > 0 then
    -- con clock MIDI el equipo repite las teclas apretadas a cada pulso:
    -- si la tecla se soltó hace poco, sigue apretada y no se redispara
    if repeat_off[msg.note] then repeat_off[msg.note] = nil; return end
    on_note_on(msg.note, msg.vel)
  elseif msg.type == "note_off" or (msg.type == "note_on" and msg.vel == 0) then
    if ext_clock_on() then
      local note = msg.note
      local tok = {}
      repeat_off[note] = tok
      local wait = util.clamp((tick_sec or 0.02) * 30, 0.05, 1)
      clock.run(function()
        clock.sleep(wait)
        if repeat_off[note] == tok then repeat_off[note] = nil; on_note_off(note) end
      end)
    else
      on_note_off(msg.note)
    end
  end
end

-- ============================================================
-- parámetros (se guardan solos en data/chordexabnt/estado.pset)
-- ============================================================

local STATE_FILE

-- un preset carga todo el sonido y el modo de movimiento (no prende ni
-- apaga el movimiento, no toca acorde ni volumen)
local function load_preset()
  local p = cur_preset()
  params:set("atk", p.a); params:set("dec", p.d); params:set("sus", p.s); params:set("rel", p.r)
  params:set("forma", p.fo); params:set("osc2", p.o2); params:set("int2", p.i2)
  params:set("sub", p.sb); params:set("det", p.dt); params:set("aire", p.ai)
  params:set("grano", p.gr); params:set("cut", p.c); params:set("res", p.q)
  params:set("fenv", p.fe); params:set("mov", p.mv); params:set("movr", p.mr)
  params:set("drive", p.dr); params:set("glide", p.gl); params:set("bass", p.bs)
  params:set("oct", p.o); params:set("chorus", p.ch); params:set("eco", p.e)
  params:set("ecofb", p.ef); params:set("ecot_div", p.et)
  params:set("shimmer", p.sh); params:set("space", p.h)
  params:set("mot_mode", p.mm); params:set("mot_depth", p.md)
  if current_note then sound_chord(current_note) end
end

local eco_sent = 0
local function update_eco_time()
  local t = beat_seconds() * ECO_DIV[pv("ecot_div")]
  if math.abs(t - eco_sent) > 0.005 then eco_sent = t; engine.ecot(t) end
end

-- movimiento: modo (0 = apagado), profundidad y velocidad en Hz a tempo
local mot_sent = ""
local function send_motion()
  if not params.lookup["mot_div"] then return end
  local on = pv("mot_on") == 2
  local hz = 1 / (beat_seconds() * MOT_DIV[pv("mot_div")])
  local key = string.format("%d %.3f %.4f", on and pv("mot_mode") or 0, pv("mot_depth"), hz)
  if key ~= mot_sent then
    mot_sent = key
    engine.motion(on and pv("mot_mode") or 0, pv("mot_depth"), hz)
  end
end

local function ctl(id, name, mn, mx, def, unit, fn, warp)
  params:add_control(id, name, controlspec.new(mn, mx, warp or "lin", 0, def, unit or ""))
  params:set_action(id, fn)
end

local function add_params()
  params:add_separator("chordex_abnt", "CHORDEX ABNT")
  params:add_number("midi_channel", "canal MIDI (0=todos)", 0, 16, 0)
  params:add_option("midi_clock_div", "divisor reloj MIDI", {"1x", "2x", "4x", "8x"}, 3)
  params:add_option("fam", "familia", fam_names, 1)
  params:set_action("fam", function(v)
    if not loading then
      -- LEAD entra monofónico con glide; las otras familias, polifónicas
      params:set("mono", FAMS[v].mono and 2 or 1)
      if pv("preset") ~= 1 then params:set("preset", 1) else load_preset() end
    end
  end)
  params:add_number("preset", "preset", 1, 8, 1)
  params:set_action("preset", function()
    if not loading then load_preset() end
  end)
  params:add_option("chord", "acorde", chord_types, 1)
  params:set_action("chord", function()
    if current_note then sound_chord(current_note) end
  end)
  params:add_option("chord_on", "modo acorde", {"no", "sí"}, 2)
  params:set_action("chord_on", function()
    if current_note and not loading then sound_chord(current_note) end
  end)
  params:add_option("mono", "mono (lead)", {"no", "sí"}, 1)
  params:add_separator("chordex_abnt_mov", "MOVIMIENTO")
  params:add_option("mot_on", "movimiento", {"no", "sí"}, 1)
  params:set_action("mot_on", function() send_motion() end)
  params:add_option("mot_mode", "modo", MOT_NAMES, 1)
  params:set_action("mot_mode", function(v)
    if not loading then params:set("mot_div", MOT_DEF_DIV[v]) end
    send_motion()
  end)
  params:add_control("mot_depth", "profundidad", controlspec.new(0, 1, "lin", 0, 0.5, ""))
  params:set_action("mot_depth", function() send_motion() end)
  params:add_option("mot_div", "velocidad", MOT_DIV_NAMES, 7)
  params:set_action("mot_div", function() send_motion() end)
  -- strum: división del pulso entre nota y nota; + de la primera nota a la
  -- última, - de la última a la primera, 0 = apagado
  params:add_number("strum", "strum (división, +/- = sentido)", -#strum_div_names, #strum_div_names, 0,
    function(p) return strum_text(p:get()) end)

  params:add_separator("chordex_abnt_osc", "OSCILADORES")
  ctl("forma", "forma (sierra-triáng.)", 0, 0.5, 0.1, "", function(v) engine.forma(v) end)
  ctl("osc2", "osc B", 0, 1, 0.3, "", function(v) engine.osc2(v) end)
  params:add_option("int2", "intervalo osc B", INT2_NAMES, 4)
  params:set_action("int2", function(v) engine.int2(INT2[v]) end)
  ctl("sub", "sub", 0, 1, 0.2, "", function(v) engine.sub(v) end)
  ctl("det", "desafinación", 0, 1, 0.4, "", function(v) engine.det(v) end)
  ctl("aire", "aire (ruido)", 0, 1, 0.05, "", function(v) engine.aire(v) end)
  ctl("grano", "grano", 0, 1, 0, "", function(v) engine.grano(v) end)
  ctl("glide", "glide", 0, 1, 0, "s", function(v) engine.glide(v) end)
  params:add_number("oct", "octava", -2, 2, 0)
  ctl("bass", "bajo", 0, 1, 0.4, "", function(v) engine.bass(v) end)

  params:add_separator("chordex_abnt_env", "ENVOLVENTE / FILTRO")
  ctl("atk", "ataque", 0.001, 6, 0.4, "s", function(v) engine.atk(v) end)
  ctl("dec", "decay", 0.05, 6, 1.2, "s", function(v) engine.dec(v) end)
  ctl("sus", "sustain", 0, 1, 0.8, "", function(v) engine.sus(v) end)
  ctl("rel", "release", 0.02, 10, 2, "s", function(v) engine.rel(v) end)
  ctl("cut", "cutoff", 0, 1, 0.55, "", function(v) engine.cut(v) end)
  ctl("res", "resonancia", 0, 1, 0.2, "", function(v) engine.res(v) end)
  ctl("fenv", "env filtro", 0, 1, 0.2, "", function(v) engine.fenv(v) end)
  ctl("mov", "movimiento (LFO)", 0, 1, 0.25, "", function(v) engine.mov(v) end)
  ctl("movr", "velocidad LFO", 0.02, 8, 0.2, "Hz", function(v) engine.movr(v) end, "exp")
  ctl("drive", "distorsión", 0, 1, 0.05, "", function(v) engine.drive(v) end)

  params:add_separator("chordex_abnt_fx", "FX")
  ctl("chorus", "chorus", 0, 1, 0.4, "", function(v) engine.chorus(v) end)
  ctl("eco", "eco", 0, 1, 0, "", function(v) engine.eco(v) end)
  ctl("ecofb", "eco repeticiones", 0, 0.85, 0.5, "", function(v) engine.ecofb(v) end)
  params:add_option("ecot_div", "eco tiempo", ECO_NAMES, 2)
  params:set_action("ecot_div", function() eco_sent = 0; update_eco_time() end)
  ctl("shimmer", "shimmer", 0, 1, 0, "", function(v) engine.shimmer(v * v) end)
  ctl("space", "hall", 0, 0.8, 0.3, "", function(v) engine.space(v) end)
  ctl("gain", "volumen", 0, 1.5, 1.0, "", function(v) engine.gain(v) end)
end

-- ============================================================
-- init / controles
-- ============================================================

local screen_metro
local splash_start = nil
-- primero la intro U-MA de particulas (la de uma_splash/splash), despues CHORDEX
local SPLASH_IN, SPLASH_HOLD, SPLASH_FADE = 0.5, 1.6, 0.7
local uma_intro = include("lib/uma_splash_particles")
local uma_sound = include("lib/uma_splash") -- base de la intro, maneja el sonido

local function skip_splash()
  if splash_start and util.time() - splash_start < uma_intro.DUR then uma_sound.sound_off() end
  splash_start = nil
end

function init()
  midi_in = {}
  for i = 1, #midi.vports do
    midi_in[i] = midi.connect(i)
    midi_in[i].event = midi_event
  end

  add_params()
  STATE_FILE = norns.state.data .. "estado.pset"
  loading = true
  if util.file_exists(STATE_FILE) then
    params:read(STATE_FILE)
    params:bang()
  else
    params:bang()
    loading = false
    load_preset()
  end
  loading = false
  engine.crackle(0)   -- el crackle de los Chordex queda apagado
  update_eco_time()

  uma_sound.sound_on(norns.state.path .. "lib/uma_particles.wav")
  splash_start = util.time()
  screen_metro = metro.init(function() redraw() end, 1 / 24, -1)
  screen_metro:start()
end

function cleanup()
  if STATE_FILE then params:write(STATE_FILE, "chordexabnt") end
end

local function nudge(p, d)
  params:set(p.id, util.clamp(pv(p.id) + d * p.step, p.min, p.max))
end

local function strum_toggle()
  k2_turned = true; k3_turned = true
  strum_ui = not strum_ui
  strum_t = util.time()
end

function enc(n, d)
  if splash_start or not params.lookup["fam"] then return end
  local dir = d > 0 and 1 or -1
  -- panel de strum abierto: E3 = división del pulso (+ / - = sentido)
  if strum_ui and n == 3 then
    strum_t = util.time()
    if k2_held then k2_turned = true end
    if k3_held then k3_turned = true end
    params:set("strum", util.clamp(pv("strum") + dir, -#strum_div_names, #strum_div_names))
    return
  end
  if n == 1 then
    if k2_held then
      params:set("mot_depth", util.clamp(pv("mot_depth") + d * 0.02, 0, 1))
      k2_turned = true
      mot_flash = PULSE * 2
    elseif k3_held then
      k3_turned = true
      -- los 32 presets en fila: al pasar el 8 entra a la familia siguiente
      local g = util.clamp((pv("fam") - 1) * 8 + pv("preset") + dir, 1, #FAMS * 8)
      local f, pr = math.floor((g - 1) / 8) + 1, (g - 1) % 8 + 1
      if f ~= pv("fam") then params:set("fam", f) end
      params:set("preset", pr)
      model_flash = PULSE * 2
    else
      params:set("cut", util.clamp(pv("cut") + d * 0.01, 0, 1))
      bump("cut")
    end
  elseif n == 2 then
    if k2_held then
      params:set("mot_mode", ((pv("mot_mode") - 1 + dir) % #MOT_NAMES) + 1)
      k2_turned = true
      mot_flash = PULSE * 2
    elseif k3_held then
      k3_turned = true
      params:set("space", util.clamp(pv("space") + d * 0.01, 0, 0.8))
      bump("space")
    else
      focus_index = ((focus_index - 1 + dir) % #P) + 1
      bump(P[focus_index].id)
    end
  elseif n == 3 then
    if k2_held then
      params:set("mot_div", util.clamp(pv("mot_div") + dir, 1, #MOT_DIV))
      k2_turned = true
      mot_flash = PULSE * 2
    elseif k3_held then
      k3_turned = true
      params:set("chord", util.clamp(pv("chord") + dir, 1, #chord_types))
      chord_flash = PULSE * 2
    else
      nudge(P[focus_index], d)
      bump(P[focus_index].id)
    end
  end
end

function key(n, z)
  if not params.lookup["fam"] then return end
  -- K1 llega acá solo si se mantiene (el toque corto abre el menú de norns)
  if n == 1 then
    if z == 1 then
      if splash_start then skip_splash() end
      set_hold(not hold_on)
    end
  elseif n == 2 then
    if z == 1 then
      k2_held = true; k2_turned = false
      if k3_held then strum_toggle() end
    else
      if splash_start then skip_splash()
      elseif k2_held and not k2_turned then
        params:set("mot_on", 3 - pv("mot_on"))
        mot_flash = PULSE
      end
      k2_held = false
    end
  elseif n == 3 then
    k3_held = (z == 1)
    if z == 1 and splash_start then skip_splash() end
    if z == 1 then
      -- mantener K3 sin girar ningún encoder alterna el modo acorde
      k3_turned = false
      if k2_held then strum_toggle() end
      local press = util.time()
      k3_press = press
      clock.run(function()
        clock.sleep(K3_LONG)
        if k3_held and not k3_turned and k3_press == press then
          params:set("chord_on", 3 - params:get("chord_on"))
          chord_flash = PULSE * 2
        end
      end)
    end
  end
end

-- ============================================================
-- GRÁFICOS — acumulador por nivel (mismo esquema que los otros Chordex)
-- ============================================================

local G = {}
do
local bt, b1, b2, b3, b4, bn = {}, {}, {}, {}, {}, {}
for lv = 1, 15 do bt[lv] = {}; b1[lv] = {}; b2[lv] = {}; b3[lv] = {}; b4[lv] = {}; bn[lv] = 0 end

local function add(lv, ty, a, b, c, d)
  lv = math.floor(lv + 0.5)
  if lv < 1 then return end
  if lv > 15 then lv = 15 end
  local n = bn[lv] + 1
  bn[lv] = n
  bt[lv][n] = ty; b1[lv][n] = a; b2[lv][n] = b; b3[lv][n] = c; b4[lv][n] = d
end

function G.px(lv, x, y) add(lv, 0, x, y) end
function G.line(lv, x1, y1, x2, y2) add(lv, 3, x1, y1, x2, y2) end
function G.rect(lv, x, y, w, h) add(lv, 4, x, y, w, h) end
function G.circle(lv, x, y, r) add(lv, 5, x, y, r) end

function G.flush()
  local floor = math.floor
  for lv = 1, 15 do
    local n = bn[lv]
    if n > 0 then
      local T, A, B, C, D = bt[lv], b1[lv], b2[lv], b3[lv], b4[lv]
      screen.level(lv)
      local fills, strokes = false, false
      for k = 1, n do
        local ty = T[k]
        if ty == 0 then
          screen.rect(floor(A[k]), floor(B[k]), 1, 1); fills = true
        elseif ty == 4 then
          screen.rect(floor(A[k]), floor(B[k]), C[k], D[k]); fills = true
        else
          strokes = true
        end
      end
      if fills then screen.fill() end
      if strokes then
        for k = 1, n do
          local ty = T[k]
          if ty == 3 then
            screen.move(floor(A[k]) + 0.5, floor(B[k]) + 0.5)
            screen.line(floor(C[k]) + 0.5, floor(D[k]) + 0.5)
          elseif ty == 5 then
            screen.move(floor(A[k]) + 0.5 + C[k], floor(B[k]) + 0.5)
            screen.circle(floor(A[k]) + 0.5, floor(B[k]) + 0.5, C[k])
          end
        end
        screen.stroke()
      end
      bn[lv] = 0
    end
  end
end
end


-- envolvente simulada (la misma ADSR que el engine)
local function env_at(vs, t)
  if not vs then return 0 end
  local a, d, s, r = pv("atk") + 0.002, pv("dec"), pv("sus"), pv("rel")
  local function held(el)
    if el < a then return el / a end
    return s + (1 - s) * math.exp(-(el - a) / math.max(0.01, d) * 3)
  end
  local e
  if vs.pluck then
    local g = vs.dur * 0.5
    local el = t - vs.t0
    local rr = math.max(vs.dur * 0.9, math.min(r, vs.dur * 4)) + 0.04
    if el < g then e = held(el)
    else e = held(g) * math.max(0, 1 - (el - g) / rr) end
  else
    local t1 = vs.t1 or t
    e = held(t1 - vs.t0)
    if vs.t1 then
      local x = (t - vs.t1) / math.max(0.02, r)
      e = x >= 1 and 0 or e * (1 - x) * (1 - x)
    end
  end
  return util.clamp(e, 0, 1) * (0.6 + vs.vel * 0.4)
end

-- LFO del engine (para que la pantalla se mueva igual)
local function lfo_at(t) return math.sin(2 * math.pi * pv("movr") * t) end

-- movimiento: fase (0..1), corrimiento del filtro (oct), volumen y giro
local function mot_hz() return 1 / (beat_seconds() * MOT_DIV[pv("mot_div")]) end
local MV = {u = 0, cut = 0, amp = 1, rot = 0, on = false}
local function mot_vis(t, dt)
  MV.on = pv("mot_on") == 2
  MV.u = (MV.u + dt * mot_hz()) % 1
  local m, dp, u = pv("mot_mode"), pv("mot_depth"), MV.u
  local tw = 2 * math.pi
  local cut, amp, rot = 0, 1, 0
  if MV.on then
    if m == 1 then cut = -math.cos(tw * u) * dp * 2.5
    elseif m == 2 then cut = (math.sin(tw * t * mot_hz() * 1.4) * 0.6 + math.sin(tw * t * mot_hz() * 3.1 + 1) * 0.4) * dp * 2.2
    elseif m == 3 then amp = 1 - dp * 0.45 * (1 + math.sin(tw * u))
    elseif m == 4 then amp = u < 0.5 and 1 or 1 - dp * 0.95
    elseif m == 5 then rot = u * tw * dp
    else amp = 1 - dp * 0.85 * (0.5 - 0.5 * math.cos(tw * u)) end
  end
  -- suave, como los Lag del engine
  local k = math.min(1, dt * 12)
  MV.cut = MV.cut + (cut - MV.cut) * k
  MV.amp = MV.amp + (amp - MV.amp) * (m == 4 and 1 or k)
  MV.rot = rot
end

-- forma de cada modo para dibujar la curva (-1..1)
local function mot_shape(m, u)
  local tw = 2 * math.pi
  if m == 1 then return -math.cos(tw * u)
  elseif m == 2 then return math.sin(tw * u * 2) * 0.6 + math.sin(tw * u * 5 + 1) * 0.4
  elseif m == 3 then return math.sin(tw * u)
  elseif m == 4 then return u < 0.5 and 1 or -1
  elseif m == 5 then return u * 2 - 1
  else return math.cos(tw * u) end
end

local function sounding()
  return VS.chord
end

-- ============================================================
-- la voz calculada en Lua (misma receta que el engine) para dibujar
-- ============================================================

local V = {N = 96, y = {}, spec = {}, amp = 0, fe = 0, tw = {}}
for k = 1, V.N do V.y[k] = 0 end
for h = 1, 14 do V.spec[h] = 0 end

local function varsaw(ph, w)
  w = util.clamp(w, 0.01, 0.5)
  if ph < w then return -1 + 2 * ph / w end
  return 1 - 2 * (ph - w) / (1 - w)
end

-- 2 ciclos de la nota = 1 ciclo del sub (así la flor cierra)
local function compute_voice(t)
  local vs = sounding()
  V.amp = env_at(VS.chord, t)
  local fo, o2, i2, sb = pv("forma"), pv("osc2"), INT2[pv("int2")], pv("sub")
  local lfo = lfo_at(t)
  local note = (vs and vs.note) or (last_note or 57)
  local f = note_to_hz(note)
  local vel = vs and vs.vel or 0.6
  local fe = 0
  if vs then
    local el, a = t - vs.t0, math.max(0.005, pv("atk"))
    fe = (el < a) and el / a or math.exp(-(el - a) / (pv("dec") + 0.1) * 3)
    fe = fe * vel
  end
  V.fe = fe
  V.amp = V.amp * MV.amp
  local fc = 60 * 2 ^ (pv("cut") * 8.3 + MV.cut) * (1 + fe * pv("fenv") * 4)
    * 2 ^ (lfo * pv("mov") * 1.2) * (f / 261.6) ^ 0.3
  V.fc = fc
  local per = V.N / 2
  local a = math.min(1, 1 - math.exp(-2 * math.pi * fc / (f * per)))
  local q = pv("res")
  local ys, vv, pk = 0, 0, 1e-6
  for pass = 1, 2 do
    for k = 1, V.N do
      local x = (k - 1) / per             -- 0..2 ciclos
      local v = varsaw(x % 1, fo) * 0.42
        + (((x * i2) % 1) < 0.5 and 1 or -1) * o2 * 0.35
        + math.sin(math.pi * x) * sb * 0.55
      -- filtro de 2 polos aproximado: la resonancia hace que se pase de largo
      vv = vv * (q * 0.85) + a * (v - ys)
      ys = ys + vv
      if pass == 2 then V.y[k] = ys; pk = math.max(pk, math.abs(ys)) end
    end
  end
  pk = math.max(pk, 0.5)
  for k = 1, V.N do V.y[k] = V.y[k] / pk end
  -- espectro: 14 armónicos de la nota (bins pares, la ventana dura 2 ciclos)
  local N = V.N
  for h = 1, 14 do
    local tw = V.tw[h]
    if not tw then
      tw = {c = {}, s = {}}
      for k = 1, N do
        local an = 2 * math.pi * (2 * h) * (k - 1) / N
        tw.c[k] = math.cos(an); tw.s[k] = math.sin(an)
      end
      V.tw[h] = tw
    end
    local re, im = 0, 0
    for k = 1, N do re = re + V.y[k] * tw.c[k]; im = im + V.y[k] * tw.s[k] end
    local mag = 2 * math.sqrt(re * re + im * im) / N * V.amp
    V.spec[h] = V.spec[h] * 0.5 + mag * 0.5
  end
end

-- ============================================================
-- dibujo
-- ============================================================

local CX, CY = 64, 32
local R0, RA = 15, 11
local rot = 0
local sparks, rings, comets = {}, {}, {}

local function pl(name) return (pulse[name] or 0) / PULSE end

-- cada nota: un cometa desde la rueda y un anillo (el eco lo repite)
scene_hit = function(n, vel)
  if #comets > 20 then table.remove(comets, 1) end
  comets[#comets + 1] = {pc = n % 12, r = 0, lv = 6 + vel * 9}
  if #rings > 10 then table.remove(rings, 1) end
  rings[#rings + 1] = {r = R0 + RA, lv = 5 + vel * 5, gen = 0}
end

-- panel izquierdo: la voz. A (3 sierras), B, SUB y AIRE entran al filtro
local NODES = {{x = 4, y = 6}, {x = 11, y = 6}, {x = 18, y = 6}, {x = 25, y = 6}}
local FX_, FY_ = 15, 22
local function draw_voice(t, dt)
  local e = V.amp
  local lv_in = {0.8, pv("osc2"), pv("sub"), pv("aire")}
  local cp, rp, mp = pl("cut"), pl("res"), pl("mov")
  -- el filtro se mece con el LFO
  local fx = FX_ + lfo_at(t) * pv("mov") * 2
  local fy = FY_
  -- bus de salida
  G.line(2 + e * 10, 2, 36, 28, 36)
  G.line(2 + e * 6, fx, fy + 4, fx, 35)
  for i, nd in ipairs(NODES) do
    local l = lv_in[i]
    if l > 0.02 then
      G.line(1 + l * 3 * (0.4 + e), nd.x, nd.y + 3, fx, fy - 3)
      -- partículas viajando al filtro (más nivel = más partículas)
      local np = 1 + math.floor(l * 2 + 0.5)
      for q = 0, np - 1 do
        local u = (t * (0.5 + i * 0.12) + q / np) % 1
        G.px(5 + l * e * 10, nd.x + (fx - nd.x) * u, nd.y + 3 + (fy - 3 - nd.y - 3) * u)
      end
    end
    G.circle(3 + l * (3 + e * 9), nd.x, nd.y, 2)
  end
  -- A: dos fantasmas que giran según la desafinación
  local dt_ = pv("det")
  if dt_ > 0.05 then
    for s = 0, 1 do
      local ph = t * (1 + dt_ * 4) * (s == 0 and 1 or -1)
      G.px(6 + dt_ * 9, NODES[1].x + math.cos(ph) * 3, NODES[1].y + math.sin(ph) * 3)
    end
  end
  -- AIRE: polvito alrededor
  local ai = pv("aire")
  for _ = 1, math.floor(ai * 4 * (0.3 + e)) do
    G.px(4 + math.random() * 8, NODES[4].x + math.random(-3, 3), NODES[4].y + math.random(-3, 3))
  end
  -- filtro: el punto adentro sube con el cutoff, el anillo es la resonancia
  local cut = pv("cut")
  G.circle(cp > 0 and 15 or (4 + e * 8), fx, fy, 3)
  G.rect(6 + e * 9 + cp * 6, fx - 1, fy + 1 - math.floor(cut * 3 + V.fe * pv("fenv") * 2), 2, 1)
  local res = pv("res")
  if res > 0.05 or rp > 0 then G.circle(3 + res * 7 + rp * 6, fx, fy, 5) end
  if mp > 0 then G.circle(15 * mp, fx, fy, 7) end
end

-- faders: 10 columnitas abajo a la izquierda
local FADER_ICON = {
  atk     = {"..#", ".##", "###"},   -- rampa que sube
  rel     = {"#..", "##.", "###"},   -- rampa que cae
  res     = {".#.", ".#.", "#.#"},   -- pico
  mov     = {".#.", "#.#", ".#."},   -- se mece
  det     = {"##.", "###", ".##"},   -- ondas encimadas
  aire    = {"#..", "..#", ".#."},   -- soplido
  grano   = {"#.#", "...", "#.#"},   -- granos
  eco     = {"#..", "#.#", "#.#"},   -- repeticiones
  shimmer = {".#.", "###", ".#."},   -- destello
  glide   = {"..#", ".#.", "#.."},   -- desliza
}

local function draw_faders()
  for i, p in ipairs(P) do
    local x = 1 + (i - 1) * 3
    local focused = (focus_index == i)
    local pp = pl(p.id)
    local lv = focused and 15 or (pp > 0 and 6 + 9 * pp or 6)
    G.line(focused and 3 or 1, x, 42, x, 55)
    local v = (pv(p.id) - p.min) / (p.max - p.min)
    if p.id == "atk" or p.id == "rel" then v = math.sqrt(v) end
    local cy = math.floor(54 - v * 12 + 0.5)
    G.rect(lv, x - (focused and 1 or 0), cy, focused and 3 or 2, 2)
    local low = (i % 2 == 0)
    local iy = low and 61 or 57
    local il = focused and 15 or math.floor(5 + 8 * pp + 0.5)
    if low then G.px(focused and 5 or 2, x, 57) G.px(focused and 5 or 2, x, 59) end
    local ic = FADER_ICON[p.id]
    for r = 1, 3 do
      local row = ic[r]
      for c = 1, 3 do
        if row:sub(c, c) == "#" then G.px(il, x - 2 + c, iy + r - 1) end
      end
    end
  end
end

-- la flor: la onda real en polar (desafinación = fantasma, aire = pelusa,
-- grano = se corta en pedazos)
local function draw_flower(t, dt)
  local N = V.N
  local amp = V.amp
  local lv = 4 + 11 * math.min(1, amp * 1.4 + flash * 0.3)
  local det, ai, gr = pv("det"), pv("aire"), pv("grano")
  local scale = 0.35 + 0.65 * amp
  local function pt(k, off, j)
    local a = 2 * math.pi * (k - 1) / N + rot + MV.rot + off
    local rad = R0 + RA * V.y[k] * scale + (j or 0)
    return CX + math.cos(a) * rad, CY + math.sin(a) * rad
  end
  if det > 0.05 then
    local off = det * 0.12 * math.sin(t * 2.3) + det * 0.05
    local px, py = pt(N, off)
    for k = 1, N, 2 do
      local x, y = pt(k, off)
      G.line(1 + det * 3, px, py, x, y)
      px, py = x, y
    end
  end
  local live = amp > 0.03
  local px, py = pt(N, 0)
  for k = 1, N do
    local j = (live and ai > 0.02) and (math.random() - 0.5) * ai * 3 * amp or 0
    local x, y = pt(k, 0, j)
    local cut = live and gr > 0.05 and math.random() < gr * 0.45
    if not cut then G.line(lv, px, py, x, y) end
    px, py = x, y
  end
  -- anillo del cutoff al moverlo con E1; el del hall con K3 + E2
  local function ring(v, p, rim)
    if p <= 0 then return end
    local n = 40
    for k = 1, n do
      local a = 2 * math.pi * k / n
      G.px((k / n) <= v and 15 * p or 3 * p, CX + math.cos(a) * rim, CY + math.sin(a) * rim)
    end
  end
  ring(pv("cut"), pl("cut"), R0 + RA * 1.05)
  ring(pv("space") / 0.8, pl("space"), R0 + RA + 4)
  rot = rot + dt * (0.08 + amp * 0.35)

  -- eco: anillos que se abren; al pasar el tiempo del eco nace otro más débil
  local eco, fb = pv("eco"), pv("ecofb")
  local et = beat_seconds() * ECO_DIV[pv("ecot_div")]
  local speed = 14
  for i = #rings, 1, -1 do
    local r = rings[i]
    local age = (r.r - R0 - RA) / speed
    r.r = r.r + dt * speed
    local l = r.lv * (1 - (r.r - R0 - RA) / 8)
    if l < 1.5 or r.r > 32 then table.remove(rings, i)
    else
      G.circle(math.min(10, l), CX, CY, r.r)
      if not r.echoed and eco > 0.05 and age >= et and r.gen < 4 then
        r.echoed = true
        local nl = r.lv * fb * (0.6 + eco * 0.4)
        if nl > 2.5 then rings[#rings + 1] = {r = R0 + RA, lv = nl, gen = r.gen + 1} end
      end
    end
  end

  -- shimmer: chispas que suben desde el borde
  local sh = pv("shimmer")
  if sh > 0.02 and amp > 0.02 and math.random() < sh * 0.9 then
    local a = math.random() * 2 * math.pi
    sparks[#sparks + 1] = {a = a, r = R0 + RA * 0.6, v = 6 + math.random() * 8, life = 1}
  end
  for i = #sparks, 1, -1 do
    local s = sparks[i]
    s.r = s.r + s.v * dt
    s.life = s.life - dt * 0.9
    if s.life <= 0 or s.r > 40 then table.remove(sparks, i)
    else G.px(2 + s.life * 12, CX + math.cos(s.a) * s.r, CY + math.sin(s.a) * s.r - (1 - s.life) * 4) end
  end
end

-- el acorde en la rueda de 12 notas, en el centro de la flor
local function wheel_xy(pc, rad)
  local a = (pc / 12) * 2 * math.pi - math.pi / 2
  return CX + math.cos(a) * rad, CY + math.sin(a) * rad
end

local function draw_wheel(t, dt)
  local root = current_note or last_note
  local lit = current_note ~= nil
  local W = 7
  local tones = {}
  if root then
    for _, iv in ipairs(four_tone_intervals(chord_name())) do tones[#tones + 1] = (root + iv) % 12 end
    if simple_mode() and #arp_keys > 1 and lit then
      tones = {}
      for _, n in ipairs(arp_keys) do tones[#tones + 1] = n % 12 end
    end
  end
  for pc = 0, 11 do
    local x, y = wheel_xy(pc, W)
    G.px(2, x, y)
  end
  if #tones > 0 then
    local base = lit and 1 or 0.35
    local sorted = {}
    for _, pc in ipairs(tones) do sorted[#sorted + 1] = pc end
    table.sort(sorted)
    for i = 1, #sorted do
      local a, b = sorted[i], sorted[i % #sorted + 1]
      if a ~= b then
        local x1, y1 = wheel_xy(a, W)
        local x2, y2 = wheel_xy(b, W)
        G.line((4 + 5 * V.amp) * base + chord_flash / PULSE * 6, x1, y1, x2, y2)
      end
    end
    for i, pc in ipairs(tones) do
      local x, y = wheel_xy(pc, W)
      if i == 1 then G.rect(15 * base, x - 1, y - 1, 2, 2)
      else G.px(11 * base, x, y) end
    end
  end
  for i = #comets, 1, -1 do
    local c = comets[i]
    c.r = c.r + dt * 34
    if c.r > 32 then table.remove(comets, i)
    else
      local r0 = W + c.r
      local x1, y1 = wheel_xy(c.pc, r0)
      local x2, y2 = wheel_xy(c.pc, math.max(W, r0 - 4))
      G.line(c.lv * (1 - c.r / 34), x2, y2, x1, y1)
    end
  end
end

-- panel derecho: familia/preset, osciloscopio, espectro, arpegio
local function draw_right(t)
  local x0 = 98
  -- familia: 4 rayitas; preset: 8 puntos debajo
  for f = 1, #FAMS do
    G.rect(pv("fam") == f and 12 or 2, x0 + 1 + (f - 1) * 4, 0, 3, 1)
  end
  for p = 1, 8 do
    G.px(pv("preset") == p and 12 or 2, x0 + 1 + (p - 1) * 2, 2)
  end
  -- mono: un puntito más a la derecha
  if is_mono() then G.px(10, x0 + 18, 2) end
  -- retener: rombo de 3x3 arriba a la derecha
  local lk = hold_on and (current_note and 13 or 8) or 3
  lk = math.min(15, lk + hold_flash * 0.25)
  G.px(lk, 125, 0) G.px(lk, 124, 1) G.px(lk, 126, 1) G.px(lk, 125, 2)
  if hold_on then G.px(lk, 125, 1) end

  -- osciloscopio: un ciclo de la nota
  local per = V.N / 2
  local mid = 12
  local lv = 4 + 11 * math.min(1, V.amp * 1.5)
  local sc = 0.2 + 0.8 * V.amp
  local px, py
  for xx = 0, 29 do
    local k = math.floor(xx / 29 * (per - 1)) + 1
    local y = mid - V.y[k] * 7 * sc
    if px then G.line(lv, px, py, x0 + xx, y) end
    px, py = x0 + xx, y
  end

  -- espectro: 14 armónicos
  local base = 50
  for h = 1, 14 do
    local x = x0 + 1 + (h - 1) * 2
    local m = math.sqrt(V.spec[h]) * 26
    local hh = math.min(26, math.floor(m + 0.5))
    if hh > 0 then
      for y = 0, hh - 1 do
        local u = y / 26
        G.px(3 + 12 * (1 - u) * math.min(1, V.amp * 2 + 0.3), x, base - 1 - y)
      end
    end
  end

  -- movimiento: la curva del modo con un punto que la recorre
  local m = pv("mot_mode")
  local blink = (math.floor(t * 6) % 2 == 0)
  local cl = k2_held and (blink and 12 or 8) or (MV.on and 6 or 2)
  local cy, ch = 58, 3
  local ppx, ppy
  for xx = 0, 27, (MV.on or k2_held) and 1 or 2 do
    local y = cy - mot_shape(m, xx / 27) * ch
    if MV.on or k2_held then
      if ppx then G.line(cl, ppx, ppy, x0 + 1 + xx, y) end
    else
      G.px(cl + 2, x0 + 1 + xx, y)
    end
    ppx, ppy = x0 + 1 + xx, y
  end
  if MV.on then
    local ux = math.floor(MV.u * 27 + 0.5)
    G.rect(15, x0 + ux, math.floor(cy - mot_shape(m, MV.u) * ch) - 1, 3, 3)
  end
  -- abajo: modo (6 puntos) y profundidad (rayita)
  for k = 1, #MOT_NAMES do
    G.px(k == m and (MV.on and 15 or 8) or 2, x0 + 1 + (k - 1) * 2, 63)
  end
  local gl = math.floor(pv("mot_depth") * 16 + 0.5)
  if gl > 0 then G.line(k2_held and 10 or (MV.on and 5 or 2), x0 + 13, 63, x0 + 13 + gl, 63) end
end

-- dibujos de las familias (aparecen al cambiar de preset con K3 + E1)
local FAM_ICON = {
  PAD = {
    "   ######      ",
    " ##++++++##    ",
    "#++++++++++####",
    "#+++++++++++++#",
    " ############# ",
    "               ",
    " ............. ",
  },
  AMBIENT = {
    "     #       . ",
    "    ###        ",
    "  #######   .  ",
    "    ###        ",
    "     #     ##  ",
    " .        #++# ",
    "     .     ##  ",
  },
  LEAD = {
    "          ###  ",
    "          #++# ",
    "          #  # ",
    "     ######    ",
    "    #++++#     ",
    "  ##+++++#     ",
    " #++++++#      ",
  },
  TEXTURE = {
    "#  .  #  .  #  ",
    "  #  .  #  .  #",
    ".  #  .  #  .  ",
    "  .  #  .  #  .",
    "#  .  #  .  #  ",
    "  #  .  #  .  #",
    ".  #  .  #  .  ",
  },
}
local ICON_LV = {["#"] = 15, ["+"] = 9, ["."] = 4}

-- panel de strum: E3 elige la división (con signo = sentido)
local function draw_strum_panel()
  local x0, y0, w, h = 26, 18, 76, 28
  screen.level(0)
  screen.rect(x0, y0, w, h)
  screen.fill()
  screen.font_face(1)
  screen.font_size(8)
  screen.level(15)
  screen.move(x0 + 4, y0 + 9)
  screen.text("STRUM")
  local v = pv("strum")
  screen.level(v == 0 and 6 or 15)
  screen.move(x0 + 4, y0 + 21)
  screen.text(strum_text(v))
  screen.level(6)
  screen.move(x0 + 4 + screen.text_extents(strum_text(v)) + 5, y0 + 21)
  screen.text("E3")
  if v ~= 0 then
    local n = 4
    local sx = x0 + w - 4 - (n - 1) * 4 - 2
    local step = math.max(0.03, strum_step())
    local lit = math.floor(util.time() / step) % (n + 3) + 1
    for i = 1, n do
      local hgt = math.floor((i - 1) * 14 / (n - 1) + 0.5)
      if v < 0 then hgt = 14 - hgt end
      G.rect(i == lit and 15 or 8, sx + (i - 1) * 4, y0 + 22 - hgt, 3, 2)
    end
  end
  G.flush()
end

local function draw_overlays()
  if strum_ui then
    draw_strum_panel()
  elseif mot_flash > 0 then
    local a = math.min(1, mot_flash / PULSE)
    local txt = MOT_NAMES[pv("mot_mode")] .. " " .. MOT_DIV_NAMES[pv("mot_div")]
      .. " " .. string.format("%02d", math.floor(pv("mot_depth") * 99 + 0.5))
    if pv("mot_on") == 1 then txt = txt .. " OFF" end
    screen.font_face(1)
    screen.font_size(8)
    local w = screen.text_extents(txt)
    screen.level(0)
    screen.rect(CX - w / 2 - 3, CY - 6, w + 6, 11)
    screen.fill()
    screen.level(math.floor(15 * a))
    screen.move(CX - w / 2, CY + 2)
    screen.text(txt)
  elseif model_flash > 0 then
    -- dibujo de la familia + nombre del preset
    local a = math.min(1, model_flash / PULSE)
    local rows = FAM_ICON[cur_fam().name]
    local w, h = #rows[1], #rows
    local name = cur_preset().n
    screen.font_face(1)
    screen.font_size(8)
    local tw = screen.text_extents(name)
    local bw = math.max(w, tw) + 6
    local x0, y0 = math.floor(CX - w / 2), CY - 10
    screen.level(0)
    screen.rect(math.floor(CX - bw / 2), y0 - 3, bw, h + 16)
    screen.fill()
    for ch, l in pairs(ICON_LV) do
      local lv = math.floor(l * a + 0.5)
      if lv > 0 then
        screen.level(lv)
        for y = 1, h do
          local r = rows[y]
          for x = 1, w do
            if r:sub(x, x) == ch then screen.rect(x0 + x - 1, y0 + y - 1, 1, 1) end
          end
        end
        screen.fill()
      end
    end
    screen.level(math.floor(15 * a))
    screen.move(CX - tw / 2, y0 + h + 9)
    screen.text(name)
  elseif chord_flash > 0 or k3_held then
    -- nombre del acorde, solo mientras se elige (K3)
    local root = current_note or last_note
    local txt = (root and note_names[(root % 12) + 1] or "") ..
      (chord_suffix[chord_name()] ~= "" and chord_suffix[chord_name()] or (root and "" or "maj"))
    if pv("chord_on") == 1 or is_mono() then txt = root and note_names[(root % 12) + 1] or "1" end
    screen.font_face(1)
    screen.font_size(8)
    local w = screen.text_extents(txt)
    local a = k3_held and 1 or math.min(1, chord_flash / PULSE)
    screen.level(0)
    screen.rect(CX - w / 2 - 2, CY - 5, w + 4, 9)
    screen.fill()
    screen.level(math.floor(15 * a))
    screen.move(CX - w / 2, CY + 2)
    screen.text(txt)
  end
end

-- ---- splash ----
local function draw_splash(alpha)
  screen.clear()
  local lv = math.max(0, math.min(15, math.floor(15 * alpha)))
  screen.level(lv)
  screen.font_face(1)
  screen.font_size(16)
  local txt = "C H O R D E X"
  local w = screen.text_extents(txt)
  screen.move(64 - w / 2, 30)
  screen.text(txt)
  -- "ABNT": tres ondas suaves que se cruzan debajo
  local t = util.time()
  for i = 1, 3 do
    screen.level(math.max(0, math.floor((3 + i * 2) * alpha)))
    local px, py
    for x = 0, 60, 2 do
      local y = 42 + math.sin(x / 60 * 2 * math.pi * (1 + i * 0.5) + t * (0.7 + i * 0.4)) * (1.5 + i)
      if px then screen.move(px, py); screen.line(34 + x, y) end
      px, py = 34 + x, y
    end
    screen.stroke()
  end
  screen.update()
end

local function tick(dt)
  for k, v in pairs(pulse) do pulse[k] = math.max(0, v - 1) end
  model_flash = math.max(0, model_flash - 1)
  mot_flash = math.max(0, mot_flash - 1)
  chord_flash = math.max(0, chord_flash - 1)
  hold_flash = math.max(0, hold_flash - 1)
  if strum_ui and util.time() - strum_t > STRUM_CLOSE then strum_ui = false end
  flash = math.max(0, flash - dt * 3)
end

local eco_timer = 0
function redraw()
  local now = util.time()
  if splash_start then
    local e = now - splash_start
    if e < uma_intro.DUR then
      uma_intro.render(e)
      screen.update()
      return
    end
    e = e - uma_intro.DUR
    local t1 = SPLASH_IN
    local t2 = t1 + SPLASH_HOLD
    local t3 = t2 + SPLASH_FADE
    if e < t1 then draw_splash(e / SPLASH_IN) return
    elseif e < t2 then draw_splash(1) return
    elseif e < t3 then draw_splash(1 - (e - t2) / SPLASH_FADE) return
    else splash_start = nil end
  end

  local dt = last_t and math.min(0.2, now - last_t) or 1 / 24
  last_t = now
  tick(dt)
  eco_timer = eco_timer + dt
  if eco_timer > 1 then eco_timer = 0; update_eco_time(); send_motion() end
  mot_vis(now, dt)
  compute_voice(now)

  screen.clear()
  draw_flower(now, dt)
  draw_wheel(now, dt)
  draw_voice(now, dt)
  draw_faders()
  draw_right(now)
  G.flush()
  draw_overlays()
  screen.update()
end

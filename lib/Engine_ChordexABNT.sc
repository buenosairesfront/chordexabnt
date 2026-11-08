// Engine_ChordexABNT.sc
// Chordex ABNT — mismo instrumento de acordes que Chordex80 / ChordexFM /
// ChordexWT / ChordexCHIP (una tecla = un acorde de 4 tonos + bajo,
// retener, strum), con un motor SUSTRACTIVO para pads, ambient, leads y
// texturas. En vez de arpegio tiene MOVIMIENTO: el acorde queda sostenido
// y lo que cambia es el sonido.
//
// Voz (\air_voice):
//   osc A: 3 VarSaw desafinadas (det) en estéreo; forma 0 = sierra,
//          0.5 = triángulo.
//   osc B: pulso a un intervalo (int2) con PWM del LFO.
//   sub:   seno una octava abajo.
//   aire:  ruido filtrado en la altura de la nota (soplido) + brillo.
//   grano: la voz se corta en granos al azar (Dust), más denso = más granos.
//   filtro: RLPF con cutoff en un bus de control (E1, en vivo),
//          resonancia, envolvente propia y LFO (mov / movr).
//   glide: portamento; con una sola nota y glide > 0 la voz se reusa.
// Movimiento (mmode 1..6, mdepth 0..1, mrate Hz a tempo):
//   1 OLA:     el filtro sube y baja (bus motBus[0], en octavas)
//   2 DERIVA:  cutoff, forma, desafinación y osc B se van al azar, lento
//   3 RESPIRA: cada voz sube, baja y se mueve en el panorama por su cuenta
//   4 PULSO:   gate rítmico del volumen (en la entrada del FX)
//   5 GIRO:    el sonido gira en estéreo y el chorus se abre
//   6 MAREA:   el volumen crece y se retira; cuando baja crece el hall
// FX (\air_fx): movimiento (pulso/giro/marea) -> chorus -> eco ping-pong a
//   tempo -> shimmer -> hall -> compresor -> limitador.

Engine_ChordexABNT : CroneEngine {

  var voiceBus, cutBus, motBus, fxSynth, motSynth;
  var noteGroup, releasingGroup;
  var mono, monoBass;

  var atk = 0.4, dec = 1.2, sus = 0.8, rel = 2.0;
  var forma = 0.1, osc2 = 0.3, int2 = 2.0, sub = 0.2, det = 0.4;
  var aire = 0.1, grano = 0, res = 0.2, fenv = 0.2, mov = 0.3, movr = 0.2;
  var drive = 0.05, glide = 0, bass = 0.4, strumVel = 0.8;
  var mmode = 0, mdepth = 0.5, mrate = 0.25;

  alloc {
    voiceBus = Bus.audio(context.server, 2);
    cutBus = Bus.control(context.server, 1);
    cutBus.set(0.6);
    motBus = Bus.control(context.server, 4);
    motBus.setn([0, 0, 0, 0]);

    SynthDef(\air_voice, {
      arg out = 0, freq = 220, gate = 1, vel = 0.8, amp = 0.2, pan = 0,
          atk = 0.4, dec = 1.2, sus = 0.8, rel = 2, glide = 0,
          forma = 0.1, osc2 = 0.3, int2 = 2, sub = 0.2, det = 0.4,
          aire = 0.1, grano = 0, res = 0.2, fenv = 0.2, mov = 0.3, movr = 0.2,
          drive = 0.05, cutBus = 0, motBus = 0, resp = 0, rrate = 0.25;
      var env, fv, lfo, drift, f, d, oa, l, r, ob, sb, nz, sig, mot,
          fo, dt, o2, gd, gr, fe, fc, dg, sat, master, rl, ra, rp;

      env = EnvGen.kr(Env.adsr(atk + 0.002, dec, sus, rel), gate);
      fv = Lag.kr(freq, glide);
      mot = In.kr(motBus, 4);   // [cutoff (oct), forma, det, osc2]

      // LFO lento: mueve filtro, PWM y un poco la afinación
      lfo = SinOsc.kr(movr * (1 + LFNoise1.kr(0.2).range(-0.1, 0.1)), Rand(0, 2pi));
      drift = LFNoise2.kr(0.25).range(-0.0018, 0.0018);
      f = fv * (1 + (lfo * mov * 0.006) + drift);

      fo = (forma + mot[1]).clip(0, 0.5);
      dt = (det + mot[2]).clip(0, 1);
      o2 = (osc2 + mot[3]).clip(0, 1);

      // osc A: 3 VarSaw desafinadas, la del medio va a los dos lados
      d = dt * 0.012;
      oa = VarSaw.ar(f * [1 - d, 1, 1 + d], [0, 0.33, 0.66], fo);
      l = oa[0] + (oa[1] * 0.7);
      r = oa[2] + (oa[1] * 0.7);

      ob = Pulse.ar(f * int2 * (1 + (d * 0.4)), (0.5 + (lfo * mov * 0.2)).clip(0.08, 0.92));
      sb = SinOsc.ar(f * 0.5);
      nz = (BPF.ar(WhiteNoise.ar([1, 1]), f.clip(60, 9000) * 2, 0.25) * 2.2)
        + (HPF.ar(PinkNoise.ar([1, 1]), 3000) * 0.25);

      sig = ([l, r] * 0.42) + (ob * o2 * 0.35) + (sb * sub * 0.55) + (nz * aire * 0.7);

      // grano: cortes al azar, más denso con más grano
      gd = 2 + (grano * 38);
      gr = Decay2.ar(Dust.ar([gd, gd]), 0.004, 0.03 + ((1 - grano) * 0.2)).min(1);
      sig = sig * ((1 - grano) + (grano * gr * 2.4));

      // filtro: bus (E1) + movimiento + envolvente + LFO + sigue a la nota
      fe = EnvGen.kr(Env([0, 1, 0], [atk.max(0.005), dec + 0.1], [2, -4])) * vel;
      fc = 60 * (2 ** ((In.kr(cutBus, 1).clip(0, 1) * 8.3) + Lag.kr(mot[0], 0.05)))
        * (1 + (fe * fenv * 4))
        * (2 ** (lfo * mov * 1.2))
        * ((fv / 261.6) ** 0.3);
      sig = RLPF.ar(sig, fc.clip(30, 18000), (1 - (res * 0.9)).max(0.08))
        * (1 - (res * 0.3));

      dg = 1 + (drive.pow(1.4) * 9);
      sat = (sig * dg).tanh;
      sig = (sig * (1 - drive.min(1))) + (sat * drive.min(1) / (1 + (drive * 0.8)));
      sig = HPF.ar(sig, 35);

      // RESPIRA: cada voz con su propia ola de volumen y de panorama
      rl = Lag.kr(resp, 0.5);
      ra = SinOsc.kr(rrate * Rand(0.6, 1.4), Rand(0, 2pi));
      rp = SinOsc.kr(rrate * Rand(0.3, 0.7), Rand(0, 2pi));
      sig = sig * (1 - (rl * 0.9 * (0.5 + (0.5 * ra))));

      master = EnvGen.kr(Env.asr(0, 1, rel + 0.08), gate, doneAction: 2);
      sig = sig * env * master * amp * (0.45 + (Lag.kr(vel, 0.03) * 0.55));
      Out.ar(out, Balance2.ar(sig[0], sig[1], (Lag.kr(pan, 0.05) + (rp * rl * 0.8)).clip(-1, 1)));
    }).add;

    // bajo: seno + un poco de triángulo, redondo
    SynthDef(\air_bass, {
      arg out = 0, freq = 55, gate = 1, atk = 0.1, rel = 1, glide = 0, drive = 0.05, amp = 0.3;
      var env, fv, sig;
      env = EnvGen.kr(Env.asr(atk.min(1.5) + 0.005, 1, rel), gate, doneAction: 2);
      fv = Lag.kr(freq, glide);
      sig = SinOsc.ar(fv) + (LFTri.ar(fv) * 0.25);
      sig = LPF.ar(sig, 400);
      sig = (sig * (1 + (drive * 3))).tanh / (1 + (drive * 0.6));
      Out.ar(out, Pan2.ar(sig * env * amp, 0));
    }).add;

    // movimiento de timbre (OLA, DERIVA): escribe en motBus
    SynthDef(\air_motion, {
      arg out = 0, mode = 0, depth = 0.5, rate = 0.25;
      var isO, isD, ola, der;
      isO = (mode > 0.5) * (mode < 1.5);
      isD = (mode > 1.5) * (mode < 2.5);
      ola = SinOsc.kr(rate, 1.5pi) * depth * 2.5;
      der = [LFNoise2.kr(rate * 2) * depth * 2.2,
             LFNoise2.kr(rate * 1.6) * depth * 0.25,
             LFNoise2.kr(rate * 1.3) * depth * 0.6,
             LFNoise2.kr(rate * 1.1) * depth * 0.45];
      Out.kr(out, Lag.kr([(ola * isO) + (der[0] * isD), der[1] * isD, der[2] * isD, der[3] * isD], 0.4));
    }).add;

    SynthDef(\air_fx, {
      arg in, out, chorus = 0.4, eco = 0, ecot = 0.375, ecofb = 0.5,
          shimmer = 0, space = 0.3, gain = 1.0, mode = 0, depth = 0.5, rate = 0.25;
      var sig, lfo1, lfo2, cmix, wet, fb, d, sh, verb, comp,
          ip, ig, im, pul, gir, mar, ang, ch, sp;

      sig = In.ar(in, 2);

      // movimiento en la entrada (así el eco y el hall siguen sonando)
      ip = Lag.kr((mode > 3.5) * (mode < 4.5), 0.3);   // PULSO
      ig = Lag.kr((mode > 4.5) * (mode < 5.5), 0.5);  // GIRO
      im = Lag.kr(mode > 5.5, 0.5);                   // MAREA
      pul = Lag.kr(LFPulse.kr(rate, 0, 0.5), 0.012);
      sig = sig * (1 - (ip * depth * 0.95 * (1 - pul)));
      mar = 0.5 - (0.5 * SinOsc.kr(rate, 0.5pi));     // 0 = arriba, 1 = abajo
      sig = sig * (1 - (im * depth * 0.85 * mar));
      ang = LFSaw.kr(rate) * ig * depth;
      sig = Rotate2.ar(sig[0], sig[1], ang);

      // chorus estéreo (GIRO lo abre)
      ch = (chorus + (ig * depth * 0.4)).min(1);
      lfo1 = LFTri.kr(0.37);
      lfo2 = LFTri.kr(0.61);
      cmix = LPF.ar(Mix(sig) * 0.5, 9000);
      wet = [DelayC.ar(cmix, 0.03, 0.007 + (lfo1 * 0.0025) + (lfo2 * 0.001)),
             DelayC.ar(cmix, 0.03, 0.007 - (lfo1 * 0.0025) - (lfo2 * 0.001))];
      sig = (sig * (1 - (ch * 0.25))) + (wet * ch * 0.6);

      // eco a tempo (ping-pong), la cola se oscurece de a poco
      fb = LocalIn.ar(2);
      d = DelayC.ar(sig + (fb.reverse * ecofb.clip(0, 0.85)), 2, Lag.kr(ecot, 0.3));
      LocalOut.ar(LPF.ar(HPF.ar(d, 120), 4500));
      sig = sig + (d * eco * 0.75);

      // shimmer: octava arriba dentro de un hall largo
      sh = PitchShift.ar(sig, 0.2, 2.0, 0.006, 0.02);
      sh = FreeVerb2.ar(sh[0], sh[1], 1, 0.95, 0.35);
      sig = sig + (sh * shimmer * 0.9);

      // hall: cuanto más espacio, más largo; MAREA lo agranda al bajar
      sp = space + (im * depth * mar * 0.35);
      verb = HPF.ar(sig, 180) * (sp + (shimmer * 0.3));
      verb = DelayN.ar(verb, 0.08, 0.04);
      verb = FreeVerb2.ar(verb[0], verb[1], 1, (0.8 + (space * 0.25)).min(0.98), 0.45);
      sig = sig + (verb * 1.1);

      sig = LPF.ar(HPF.ar(sig, 30), 16000);
      comp = Compander.ar(sig, Mix(sig) * 0.5, 0.25, 1, 0.5, 0.01, 0.2);
      sig = comp * 1.4 * gain;
      sig = Limiter.ar(LeakDC.ar(sig), 0.92, 0.002);
      Out.ar(out, sig);
    }).add;

    context.server.sync;

    motSynth = Synth.head(context.xg, \air_motion, [\out, motBus.index]);
    fxSynth = Synth.tail(context.xg, \air_fx, [\in, voiceBus, \out, context.out_b]);

    // f1..f4 (0 = esa voz no suena), bajo, vel
    this.addCommand("noteOn", "ffffff", { |msg|
      var freqs = [msg[1], msg[2], msg[3], msg[4]].select({ |f| f > 0 });
      var subf = msg[5], vel = msg[6], nv, s;

      if (freqs.size == 0) { freqs = [subf * 4] };
      nv = freqs.size;

      if ((glide > 0.001) and: { nv == 1 } and: { mono.notNil }) {
        // lead legato: la misma voz se desliza a la nota nueva
        mono.set(\freq, freqs[0], \vel, vel);
        if (monoBass.notNil) { monoBass.set(\freq, this.bassFreq(subf)) };
      } {
        this.newGroup;
        freqs.do({ |f, i|
          s = Synth.new(\air_voice, this.voiceArgs ++ [
            \freq, f, \vel, vel, \amp, 0.2 * ((4 / nv) ** 0.5),
            \pan, if (nv == 1) { 0 } { ((i - 1.5) * 0.4).clip(-0.9, 0.9) }
          ], noteGroup);
        });
        if (nv == 1) { mono = s; this.watchMono(s) };
        if (bass > 0) {
          monoBass = Synth.new(\air_bass, this.bassArgs(subf, 0.24 * bass), noteGroup);
        };
      };
    });

    // strum: grupo nuevo con el bajo; las notas llegan con strumNote
    this.addCommand("strumOn", "ff", { |msg|
      this.newGroup;
      strumVel = msg[2];
      if (bass > 0) { Synth.new(\air_bass, this.bassArgs(msg[1], 0.24 * bass), noteGroup) };
    });

    // frecuencia, espera (s), cantidad total de notas, pan
    this.addCommand("strumNote", "ffff", { |msg|
      var g = noteGroup, nv = msg[3].max(1);
      var args = this.voiceArgs ++ [
        \freq, msg[1], \vel, strumVel, \pan, msg[4],
        \amp, 0.2 * ((4 / nv.max(4)) ** 0.5)
      ] ++ (if (nv >= 5) { [\aire, aire * 0.3, \grano, 0] } { [] });
      if (g.notNil) {
        if (msg[2] <= 0) { Synth.new(\air_voice, args, g) } {
          SystemClock.sched(msg[2], {
            if (noteGroup === g) { Synth.new(\air_voice, args, g) };
            nil
          });
        };
      };
    });

    this.addCommand("noteOff", "", { |msg|
      var g;
      mono = nil; monoBass = nil;
      if (releasingGroup.notNil) { releasingGroup.free; releasingGroup = nil };
      if (noteGroup.notNil) {
        g = noteGroup;
        g.set(\gate, 0);
        releasingGroup = g;
        noteGroup = nil;
        SystemClock.sched(rel + 0.8, {
          if (releasingGroup === g) { g.free; releasingGroup = nil };
          nil
        });
      };
    });

    // modo (0 = apagado, 1..6), profundidad, velocidad (Hz)
    this.addCommand("motion", "iff", { |msg|
      mmode = msg[1].clip(0, 6); mdepth = msg[2]; mrate = msg[3].max(0.001);
      motSynth.set(\mode, mmode, \depth, mdepth, \rate, mrate);
      fxSynth.set(\mode, mmode, \depth, mdepth, \rate, mrate);
      this.setLive([\resp, this.respAmt, \rrate, mrate]);
      if (releasingGroup.notNil) { releasingGroup.set(\resp, this.respAmt, \rrate, mrate) };
    });

    this.addCommand("atk", "f", { |msg| atk = msg[1] });
    this.addCommand("dec", "f", { |msg| dec = msg[1] });
    this.addCommand("sus", "f", { |msg| sus = msg[1]; this.setLive([\sus, sus]) });
    this.addCommand("rel", "f", { |msg| rel = msg[1]; this.setLive([\rel, rel]) });
    this.addCommand("forma", "f", { |msg| forma = msg[1]; this.setLive([\forma, forma]) });
    this.addCommand("osc2", "f", { |msg| osc2 = msg[1]; this.setLive([\osc2, osc2]) });
    this.addCommand("int2", "f", { |msg| int2 = msg[1]; this.setLive([\int2, int2]) });
    this.addCommand("sub", "f", { |msg| sub = msg[1]; this.setLive([\sub, sub]) });
    this.addCommand("det", "f", { |msg| det = msg[1]; this.setLive([\det, det]) });
    this.addCommand("aire", "f", { |msg| aire = msg[1]; this.setLive([\aire, aire]) });
    this.addCommand("grano", "f", { |msg| grano = msg[1]; this.setLive([\grano, grano]) });
    this.addCommand("res", "f", { |msg| res = msg[1]; this.setLive([\res, res]) });
    this.addCommand("fenv", "f", { |msg| fenv = msg[1]; this.setLive([\fenv, fenv]) });
    this.addCommand("mov", "f", { |msg| mov = msg[1]; this.setLive([\mov, mov]) });
    this.addCommand("movr", "f", { |msg| movr = msg[1]; this.setLive([\movr, movr]) });
    this.addCommand("drive", "f", { |msg| drive = msg[1]; this.setLive([\drive, drive]) });
    this.addCommand("glide", "f", { |msg| glide = msg[1]; this.setLive([\glide, glide]) });
    this.addCommand("bass", "f", { |msg| bass = msg[1] });
    this.addCommand("cut", "f", { |msg| cutBus.set(msg[1]) });

    this.addCommand("chorus", "f", { |msg| fxSynth.set(\chorus, msg[1]) });
    this.addCommand("eco", "f", { |msg| fxSynth.set(\eco, msg[1]) });
    this.addCommand("ecot", "f", { |msg| fxSynth.set(\ecot, msg[1].clip(0.05, 2)) });
    this.addCommand("ecofb", "f", { |msg| fxSynth.set(\ecofb, msg[1]) });
    this.addCommand("shimmer", "f", { |msg| fxSynth.set(\shimmer, msg[1]) });
    this.addCommand("space", "f", { |msg| fxSynth.set(\space, msg[1]) });
    this.addCommand("gain", "f", { |msg| fxSynth.set(\gain, msg[1]) });
    // compatibilidad con los otros Chordex (el crackle está apagado)
    this.addCommand("crackle", "f", { |msg| });
  }

  respAmt { ^if (mmode == 3) { mdepth } { 0 } }

  watchMono { |s|
    s.onFree { if (mono === s) { mono = nil; monoBass = nil } };
  }

  newGroup {
    if (releasingGroup.notNil) { releasingGroup.free };
    if (noteGroup.notNil) {
      noteGroup.set(\gate, 0);
      releasingGroup = noteGroup;
    };
    noteGroup = Group.head(context.xg);
    mono = nil; monoBass = nil;
  }

  voiceArgs {
    ^[\out, voiceBus, \cutBus, cutBus.index, \motBus, motBus.index,
      \atk, atk, \dec, dec, \sus, sus, \rel, rel, \glide, glide,
      \forma, forma, \osc2, osc2, \int2, int2, \sub, sub, \det, det,
      \aire, aire, \grano, grano, \res, res, \fenv, fenv,
      \mov, mov, \movr, movr, \drive, drive,
      \resp, this.respAmt, \rrate, mrate]
  }

  bassArgs { |f, amp|
    ^[\out, voiceBus, \freq, this.bassFreq(f), \atk, atk, \rel, rel.max(0.15),
      \glide, glide, \drive, drive, \amp, amp]
  }

  setLive { |args|
    if (noteGroup.notNil) { noteGroup.set(*args) };
  }

  bassFreq { |f| ^if (f < 40) { f * 2 } { f } }

  free {
    if (noteGroup.notNil) { noteGroup.free };
    if (releasingGroup.notNil) { releasingGroup.free };
    motSynth.free;
    fxSynth.free;
    voiceBus.free;
    cutBus.free;
    motBus.free;
  }
}

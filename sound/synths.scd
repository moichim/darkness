/**
 * Syntetizátory
 */

(
// DEFINICE SYNŤÁKŮ

/*
SynthDef.new(\polySynth, {
	arg center, spread, voices, pan, bpfFreq, bpfQ;

	var spreadFactor, pans, freqs, signals, osc, bpf, output;

	spreadFactor = spread * 0.5; // Možnost upravit šířku sterea

	pans = ( Array.fill(voices, {Rand(-spreadFactor, spreadFactor)} );
	freqs = (Array.fill(voices, {center * (1 + Rand(-0.05, 0.05)) }));

	signals = freqs.collect({|freq|
			osc = SinOsc.ar(freq, 0, 0.3);
			bpf = BPF.ar( osc, bpfFreq, bpfQ );
			bpf * 0.5;
	});

		output = signals.collect2({
			|signal,panValue|
			Pan2.ar(signal, panValue)
		});

		output = Mix.new(output).clip(0.1);

		Out.ar(0, output);


}).add;
*/

SynthDef.new(\blip, {
	arg freq=440, atk=0.005, rel=0.5, amp=1, pan=0, out=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new(
		[0,1,0],
		[atk,rel],
		[1,-1]
	),doneAction: 2);
	sig = Pan2.ar(sig,pan,amp);
	sig = sig * amp;
	Out.ar(out,sig);
}).add;

SynthDef(\cfstring1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

SynthDef(\cfs, { arg i_out, freq = 360, gate = 1, pan, amp=0.1, lagf=0.2, lagp=0.2;
    var out, eg, fc, osc, a, b, w, smoothedFreq, smoothedAmp;

    // Plynulé přechody frekvence
    smoothedFreq = Lag.kr(freq, lagf); // Lag s hodnotou 0.2s
	smoothedAmp = Lag.kr(amp, lagp);

    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, { LFSaw.ar(smoothedFreq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, smoothedAmp) }).distort * 0.2;

    eg = EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);

    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;


// Čistá sinusovka
SynthDef.new(\sine, {
	|freq=440,atk=0.005,rel=0.5, amp=1,pan=0, out=0|
	var sig,env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new(
		[0,1,0],
		[atk,rel],
		[1,-1]
	), doneAction:2);
	sig = Pan2.ar(sig,pan,amp);
	sig = sig * env;
	Out.ar(out,sig);
}).add;

// Přehrání bufferu
SynthDef.new(
	\playbuf, {
		arg amp=1,pan=0,out=0,buf,rate=1;
		var sig;
		sig = PlayBuf.ar(1,buf, BufRateScale.kr(buf) * rate,doneAction:2);
		sig = Pan2.ar(sig,pan);
		sig = sig * amp;
		Out.ar( out, sig );
	}
).add;

// Reverb
SynthDef.new(\reverb,{
	arg in, out=0, mix=0.5,room=0.5,damp=0.5,mul=0.5;
	var sig;
	sig = In.ar(in,2);
	sig = FreeVerb.ar(sig, mix:mix,room:room,damp:damp,mul:mul);
	Out.ar(out,sig);
}).add;

SynthDef(\foldsaw, {
		arg freq=4, detune=1, atk=0.01, dec=0.3, rel=3, c1=1, c2=(-1), gate=1,
		mincf=40, maxcf=12000, minrq=0.002, maxrq=0.2, boost=1.25, amp=1, out=0, pan=0;
		var sig, env;
		env = EnvGen.kr(Env.adsr(atk,dec,0.5,rel), gate, doneAction:2);
		sig = Saw.ar(
			freq +
			LFNoise1.kr(LFNoise1.kr(0.5!8).range(0.1,1)).bipolar(detune);
		);
		5.do{sig = (sig*boost).fold(-1.0,1.0)};
		sig = BPF.ar(
			sig,
			LFNoise1.kr({ExpRand(0.005,0.05)}!8).exprange(mincf, maxcf),
			LFNoise1.kr({ExpRand(0.1,0.75)}!8).range(minrq, maxrq)
		);
		sig = Splay.ar(sig, 0.1, 1, pan) * env * amp * 2;
		Out.ar(out, sig);
	}).add;


SynthDef.new(
	\base,{
		arg freq=300, freqLow=60,atk=0.1,rel=2,pan=0;
		var sig, sigMain, sigLow, envMain, envLow;
		envMain = EnvGen.ar(Env.perc(atk,rel));
		envLow = EnvGen.ar(Env.perc(atk,rel*2));
		sigMain = SinOsc.ar(freq,0.5) *  envMain;
		sigLow = SinOsc.ar(freqLow,0.75) * envLow;
		sig = sigMain + sigLow;
		sig = Pan2.ar(sig,pan);
		Out.ar(0,sig);
	}
).add;


SynthDef.new(
	\wind, {
		arg freq=400,pan=0,amp=0.2,atk=0.05,rel=2,rq=1,reverb=0,width=1;
		var sig, env;
		env = EnvGen.kr(Env.new(
			[0,1,0],
			[atk,rel]
		),doneAction:2);
		sig = VarSaw.ar(freq,width:width);
		sig = Pan2.ar(sig,pan) * env;
		//sig = FreeVerb.ar(sig,reverb);
		//BPF.ar(sig,freq,rq);
		Out.ar(0,sig);
	}
).add;


)
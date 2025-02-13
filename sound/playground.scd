s.boot;

Scale.major.degrees

x = Synth.new(\base, [\freq, 50, \freqLow, 20 ]);

x = Synth.new(\cfs, [\freq, 20]);

x.set(\freq, 500, \lag, 20);
x.set(\freq, 30, \lag, 1);

x.free;

s.freeAll;


(
Pdef.new(
	\base,
	Pbind(
		\instrument, \base,
		\dur, Prand([0.5,0.8,1,0.6], inf),
		\freq, 200,// Pseq([150,200,400,120],inf),
		// \freqLow, Pseq([20, 40, 60, 80, 100], inf),
		\pan, Pexprand(0.1,2,inf) - 1,
		// \atk, 1 //Pwhite(0.5,1,inf),
		// \amp, Pexprand(0.2,0.5,inf),
		// \width, Pexprand(0.5,0.8,inf),
	)
).play;
)

Pdef(\base, Pbind( \pan, 0 ));

Pdef(\base).stop;

(
SynthDef(\bassChord, { |out=0, freqArray = #[65.41, 77.78, 98], amp=0.2, dur=1|
    var sig = Mix.ar(LFSaw.ar(freqArray, 0, amp)); // Mixování tří pilových vln
    sig = LPF.ar(sig, 500); // Lehké ztlumení vyšších frekvencí
    sig = sig * EnvGen.kr(Env.perc(0.1, dur), doneAction: 2);
    Out.ar(out, sig!2);
}).add;
)

Pbind(
    \instrument, \bassChord,
    \freqArray, Pseq([
        [65.41, 77.78, 98],   // C moll
        [87.31, 103.83, 130.81], // F moll
        [98, 116.54, 146.83]  // G moll
    ], inf),
    \dur, 1.5
).play;

s.quit




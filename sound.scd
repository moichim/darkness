// Spuštění zvukového serveru
s = Server.default;
// ; // Spuštění zvukového serveru

// s.quit;

// Server.local.options.device = "Aggr";
// Server.internal.options.device = "Aggr";
// s.options.sampleRate = 48000;

// s.options.outDevice;

(

// Počkejte, dokud není server připraven
s.waitForBoot({




	// n = NetAddr.new( NetAddr.localAddr.hostname, 57133 );

	~processing = NetAddr.new( NetAddr.localAddr.hostname, 47120 );







	/**
	 * Globální věci
	 */


	// Vytvoří absolutní cestu k samplu
	~path = {|relative|
		thisProcess.nowExecutingPath.dirname +/+ "/data/samples/" +/+ relative;
	};

	// Načte samply do pole samplů
	~scanFolder = {|relative|
		var abs = thisProcess.nowExecutingPath.dirname +/+ "/data/samples/" +/+ relative;
		var path = PathName.new(abs);
		path.files.collect({|file|
			Buffer.read(s, file.asAbsolutePath);
		});
	};


	/**
	 * Přehraje sample
	 * - buf = číslo bufferu
	 * - baseNote = nota, na které se nachází původní sample
	 * - targetNote = nota, na kterou se má sample namapovat
	 * Pokud není nota specifikována vůbec, tak se sample přehraje v původní podobě.
	 */
	SynthDef(\sample, {
		arg amp = 1, pan = 0, out = 0, buf, rate = 1, freq = 440;
		var sig, playbackRate;

		// Přepočet frekvence na playbackRate vůči základní frekvenci samplu
		// Předpokládáme, že sample je nahrán s výškou A4 (MIDI 69 = 440 Hz)
		playbackRate = freq / 440;

		sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate * playbackRate, doneAction: 2);
		sig = Pan2.ar(sig, pan);
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;


	SynthDef.new(
		\effector, {
			arg in, out=0, bpfFreq=1000, bpfQ=0.707;
			var signal;
			signal = In.ar(in, 2);
			signal = BPF.ar(signal, bpfFreq, bpfQ);
			Out.ar(out, signal);
		}
	).add;



	v = Bus.control(s, 1); // Speed amount 0-1
	h = Bus.control(s, 1); // Current height 0-1

	m = Bus.control(s, 1); // Minimal frequency
	n = Bus.control(s, 1); // Maximal frequency

	v.set(1);
	h.set(1);
	m.set(1);
	n.set(100);



	Ndef.new(\saber, {
		|flutterAmt=0.02, humLevel=0.3, swingThresh=0.7, swingLevel = 0.1, amp=0, pan=0, speed=1.5|

		var humPitch = In.kr(h).range(In.kr(m), In.kr(n));

		var hum, sig, flutter, swing, swingNoise, swingSwitch;

		flutter = 4.collect({
			|i|
			LFNoise0.kr(rrand(3, 16), flutterAmt, 1).lag(0.48);
		});

		hum = Mix(SyncSaw.ar([humPitch, humPitch * 1.001] * flutter.copyRange(0, 1), [humPitch * 1.003, humPitch * 1.0025] * flutter.copyRange(2, 3)));

		hum = hum * LFNoise0.kr(8.77224).range(0.2, 1.0).lag(0.4);

		hum = RLPF.ar(hum, LFNoise0.kr(21).range(200, 1800).lag(1.2), 0.5) * 0.1 * humLevel;

		humPitch = humPitch * StandardL.ar(3.8, 2.9).range(0.93, 1.07);

		swingNoise = LFNoise1.kr(16.2).range(0, 1);
		swingSwitch = if(swingNoise > swingThresh, 1, 0).lag2(0.9, 1.3);
		swingLevel = swingLevel * swingSwitch;

		humPitch = humPitch * StandardL.ar(3.8, 2.9).range(0.97, 1.03) * (1 + (swingSwitch * 0.2));

		swing = SyncSaw.ar(Lag.ar( humPitch * speed, 0.3 ), Lag.ar( humPitch * 1.09, 0.3) ) * In.kr(v);
		swing = LPF.ar(swing, 1000, 0.3);

		sig = hum + swing;

		sig = sig * Lag.kr( amp, 1 );

		sig = Pan2.ar(sig, pan);


	}).play;


	// Počkejte, dokud není SynthDef nahrán
    s.sync;


	~phase = 0;

	Pdefn(\master, 0.2);





	/**
	 * Stars
	 */

	// Samply
	~s1 = Buffer.read(s, ~path.value( "star/star_1.aiff" ));
	~s2 = Buffer.read(s, ~path.value( "star/star_2.aiff" ));
	~s3 = Buffer.read(s, ~path.value( "star/star_3.aiff" ));
	// Bus
	~sb = Bus.audio(s, 2);
	// Effector
	~se = Synth.new(\effector, [\in, ~sb]);
	~se.set(\bpfFreq, 1000, \bpfQ, 2);
	// Clock
	~sc = TempoClock.new(1.0);
	~sc.tempo = 2;


	// Proměnné

	Pdefn(\starDur, 0.5);
	Pdefn(\starMelody, Pseq([0, 1, 2, 3, 4, 0, 0], inf));
	Pdefn(\starShift, Pxrand(#[0,1,2],inf));
	Pdefn(\starPan, 0);
	Pdefn(\starAmp, 0);
	Pdefn(\starScale, Scale.minorPentatonic);
	Pdefn(\starOctave, 6);

	// Konvertor stupňů
	Pdefn(\starDegree,
		Pfuncn({
			Pdefn(\starMelody) + Pdefn(\starShift)
		}, inf)
	);

	// Konverze volume
	Pdefn(\starVolume,
		Pfuncn({
			Pdefn(\starAmp) * Pdefn(\master)
		}, inf)
	);


	Pbindef(\starPattern,
		\instrument, \sample,
		\dur, Pdefn(\starDur),
		\degree, Pdefn(\starDegree).asStream.next(1),
		\scale, Pdefn(\starScale),
		\octave, Pdefn(\starOctave),
		\amp, Pdefn(\starVolume),
		\pan, Pdefn(\starPan),
		\out, 0,
		\onNote, Pfunc({|event|
			~processing.sendMsg("/bell");
			// "spuštěno /piano".postln;
		}),
		\buf, ~s1.bufnum
	);

	// Pbindef(\starPattern).play(~sc);

	Pbindef(\starPattern).pause;

	~starPlays = false;






    OSCdef.newMatching(\bell, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];


		// Amplituda
		if (amp != amp, {
			Pdefn(\starAmp, 0);
			if (~starPlays==true,{
				Pbindef(\starPattern).stop;
				Pdefn(\starAmp, 0);
				~starPlays = false;
			});
		}, {
			if (~starPlays==false, {
				Pbindef(\starPattern).play(~sc);
				~starPlays = true;
				Pdefn(\starAmp, amp);
			},{
				Pdefn(\starAmp, amp);
			});


		} );

		// Pan
		if ( pan != pan, {
			Pdefn(\starPan, 0);
		},{
			Pdefn(\starPan, pan);
		} );

		// Height mapuje základní notu na rozsah 60 - 67
		if (h!=h, {},{

			// h.linlin(-1,1, 2, 6).round.asInteger.postln;

			if (h < 0.5,{
				// ~se.set(\bpfQ, h.linlin(0.0, 0.5, 0.3, 5.0) );
			},{
				// ~se.set(\bpfQ, h.linlin(0.5, 1.0, 5.0, 0.3) );
			});

		});

		if (speed!=speed, {
		},{});

		if (pivoty!=pivoty, {},{

			var octave = pivoty.linlin(0.0,1.0, 6, 2).floor.asInteger;

			Pdefn(\starOctave, octave);
			// Pdefn(\starmelody, pivoty.linlin(0,1,40,67).round);
		});

		if (pivotx!==pivotx,{},{

			var tempo = pivotx.linlin(0.0,1.0, 0.5, 2);

			Pdefn(\starDur, tempo);

		});

	},
	"/bell",
	recvPort: 57133
	);

	OSCdef(\bell).enable;








	// Samply
	~kytar = Buffer.read(s, ~path.value( "string/string_cut.aiff" ));
	// Bus
	~kb = Bus.audio(s, 2);
	// Effector
	~ke = Synth.new(\effector, [\in, ~sb]);
	~ke.set(\bpfFreq, 1000, \bpfQ, 2);
	// Clock
	~kc = TempoClock.new(1.0);
	~kc.tempo = 2;


	// Proměnné

	Pdefn(\kytarDur, 1);
	Pdefn(\kytarMelody, Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf));
	Pdefn(\kytarShift, Pxrand(#[0,1,2],inf));
	Pdefn(\kytarPan, 0);
	Pdefn(\kytarAmp, 0);
	Pdefn(\kytarScale, Scale.minorPentatonic);
	// Pdefn(\kytarScale, Scale.chinese);
	Pdefn(\kytarOctave, 4);

	// Konvertor stupňů
	Pdefn(\kytarDegree,
		Pfuncn({
			Pdefn(\kytarMelody) + Pdefn(\kytarShift)
		}, inf)
	);

	// Konverze volume
	Pdefn(\kytarVolume,
		Pfuncn({
			Pdefn(\kytarAmp) * Pdefn(\master)
		}, inf)
	);


	Pbindef(\kytarPattern,
		\instrument, \sample,
		\dur, Pdefn(\kytarDur),
		\degree, Pdefn(\kytarDegree).asStream.next(1),
		\scale, Pdefn(\kytarScale),
		\octave, Pdefn(\kytarOctave),
		\amp, Pdefn(\kytarVolume),
		\pan, Pdefn(\kytarPan),
		\out, 0,
		\onNote, Pfunc({|event|
			~processing.sendMsg("/kytar");
			"spuštěno /kytar".postln;
		}),
		\buf, ~kytar.bufnum
	);

	// Pbindef(\kytar, \amp, 0.5);

	Pbindef(\kytarPattern).stop;

	// Pbindef(\kytarPattern).play(~kc);

	~kytarPlays = false;






    OSCdef.newMatching(\kytar, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];

		msg.postln;

		// Amplituda
		if (amp != amp, {
			Pdefn(\kytarAmp, 0);
			if (~kytarPlays==true,{
				Pbindef(\kytarPattern).stop;
				Pdefn(\kytarAmp, 0);
				~kytarPlays = false;
			});
		}, {
			if (~kytarPlays==false, {
				Pbindef(\kytarPattern).play(~kc);
				~kytarPlays = true;
				Pdefn(\kytarAmp, amp);
			},{
				Pbindef(\kytarPattern).stop;
				~kytarPlays = false;
				Pdefn(\kytarAmp, amp);
			});


		} );

		// Pan
		if ( pan != pan, {
			Pdefn(\kytarPan, 0);
		},{
			Pdefn(\kytarPan, pan);
		} );

		// Height mapuje základní notu na rozsah 60 - 67
		if (h!=h, {},{

			// h.linlin(-1,1, 2, 6).round.asInteger.postln;

			if (h < 0.5,{
				// ~se.set(\bpfQ, h.linlin(0.0, 0.5, 0.3, 5.0) );
			},{
				// ~se.set(\bpfQ, h.linlin(0.5, 1.0, 5.0, 0.3) );
			});

		});

		if (speed!=speed, {
		},{});

		if (pivoty!=pivoty, {},{

			var octave = pivoty.linlin(0.0,1.0, 6, 2).floor.asInteger;

			Pdefn(\kytarOctave, octave);
			// Pdefn(\starmelody, pivoty.linlin(0,1,40,67).round);
		});

		if (pivotx!==pivotx,{},{

			var tempo = pivotx.linlin(0.0,1.0, 0.5, 2);

			Pdefn(\kytarDur, tempo);

		});

	},
	"/kytar",
	recvPort: 57133
	);

	OSCdef(\kytar).enable;














	~drum = Buffer.read(s, ~path.value( "drum/bassdrum02.ogg" ));
	~ding = Buffer.read(s, ~path.value( "ding/dong02.ogg" ));



	// Samply
	~piano = Buffer.read(s, ~path.value( "piano/c.wav" ));
	// Bus
	~pb = Bus.audio(s, 2);
	// Effector
	~pe = Synth.new(\effector, [\in, ~sb]);
	~pe.set(\bpfFreq, 500, \bpfQ, 1);
	// Clock
	~pc = TempoClock.new(1.0);
	~pc.tempo = 2;


	// Proměnné

	Pdefn(\pianoDur, 1);
	Pdefn(\pianoMelody, Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf));
	Pdefn(\pianoShift, Pxrand(#[0,1,2],inf));
	Pdefn(\pianoPan, 0);
	Pdefn(\pianoAmp, 0);
	Pdefn(\pianoScale, Scale.minorPentatonic);
	Pdefn(\pianoOctave, 4);

	// Konvertor stupňů
	Pdefn(\pianoDegree,
		Pfuncn({
			Pdefn(\pianoMelody) + Pdefn(\pianoShift)
		}, inf)
	);

		// Konverze volume
	Pdefn(\pianoVolume,
		Pfuncn({
			Pdefn(\pianoAmp) * Pdefn(\master)
		}, inf)
	);


	Pbindef(\pianoPattern,
		\instrument, \sample,
		\dur, Pdefn(\pianoDur),
		\degree, Pdefn(\pianoDegree).asStream.next(1),
		\scale, Pdefn(\pianoScale),
		\octave, Pdefn(\pianoOctave),
		\amp, Pdefn(\pianoVolume),
		\pan, Pdefn(\pianoPan),
		\out, 0,
		\onNote, Pfunc({|event| ~processing.sendMsg("/piano"); }),
		\buf, ~piano.bufnum
	);

	// Pbindef(\kytar, \amp, 0.5);

	// Pbindef(\pianoPattern).play(~pc);

	// Pbindef(\pianoPattern).stop;

	~pianoPlays = false;









    OSCdef.newMatching(\piano, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];



		// Amplituda pro Ndef
		if (amp != amp, {}, {
			if (amp != amp, {
			Pdefn(\pianoAmp, 0);
			if (~pianoPlays==true,{
				Pbindef(\pianoPattern).stop;
				~pianoPlays = false;
				Pdefn(\pianoAmp, 0);
			});
		}, {
			if (~pianoPlays==false, {
				Pbindef(\pianoPattern).play(~pc);
				~pianoPlays = true;
				Pdefn(\pianoAmp, amp);
			},{
				Pdefn(\pianoAmp, amp);
			});

		} );
		});

		// Pan
		if (pan != pan, {}, {
			Ndef(\saber).set(\pan, pan);
		});

		// Výška - pošle se do bussu h (který se mapuje na rozsah frekvencí)
		if (h != h, {}, {
			//h.set(h); // Bus 'h' (výška 0–1)
		});

		// Rychlost oscilace (swing)
		if (speed != speed, {}, {
			Ndef(\saber).set(\flutterAmt, speed);

			// var octave = speed.linlin(0.0,1.0, 4, 1).floor.asInteger;
			// var minFreq = 10.midicps * (2 ** (octave - 4));
			// var maxFreq = 40.midicps * (2 ** (octave - 4));
			// m.set(minFreq);
			// n.set(maxFreq);
		});

		// PivotY ovlivňuje oktávu (nepoužívá se v Ndef přímo, ale můžem použít třeba pro změnu frekvenčního rozsahu)
		if (pivoty != pivoty, {}, {
			// var octave = pivoty.linlin(0.0,1.0, 4, 1).floor.asInteger;
			// var minFreq = 10.midicps * (2 ** (octave - 4));
			// var maxFreq = 40.midicps * (2 ** (octave - 4));
			// m.set(minFreq);
			// n.set(maxFreq);
		});

		// PivotX ovlivňuje tempo, můžeš s tím třeba škálovat hlasitost nebo rychlost
		if (pivotx != pivotx,{}, {
			// var swingVolume = pivotx.linlin(0.0, 1.0, 0.0, 1.0);
			// v.set(swingVolume); // Bus 'v' pro sílu swing části
		});


		//////////

	},
	"/piano",
	recvPort: 57133
	);

	OSCdef(\piano).enable;














	// Samply

	~voice1 = Buffer.read(s, ~path.value( "voice/07_c2_rev_1.aiff" ));
	~voice2 = Buffer.read(s, ~path.value( "voice/07_c2_rev_2.aiff" ));
	~voice3 = Buffer.read(s, ~path.value( "voice/07_c2_rev_3.aiff" ));




	// Bus
	~vb = Bus.audio(s, 2);
	// Effector
	~ve = Synth.new(\effector, [\in, ~sb]);
	~ve.set(\bpfFreq, 500, \bpfQ, 1);
	// Clock
	~vc = TempoClock.new(1.0);
	~vc.tempo = 2;


	// Proměnné

	Pdefn(\voiceDur, 1);
	Pdefn(\voiceMelody, Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf));
	Pdefn(\voiceShift, Pxrand(#[0,1,2],inf));
	Pdefn(\voicePan, 0);
	Pdefn(\voiceAmp, 0);
	Pdefn(\voiceScale, Scale.minorPentatonic);
	Pdefn(\voiceOctave, 6);

	// Konvertor stupňů
	Pdefn(\voiceDegree,
		Pfuncn({
			Pdefn(\voiceMelody) + Pdefn(\voiceShift)
		}, inf)
	);

		// Konverze volume
	Pdefn(\voiceVolume,
		Pfuncn({
			Pdefn(\voiceAmp) * Pdefn(\master)
		}, inf)
	);


	Pbindef(\voicePattern,
		\instrument, \sample,
		\dur, Pdefn(\voiceDur),
		\degree, Pdefn(\voiceDegree).asStream.next(1),
		\scale, Pdefn(\voiceScale),
		\octave, Pdefn(\voiceOctave),
		\amp, Pdefn(\voiceVolume),
		\pan, Pdefn(\voicePan),
		\out, 0,
		\onNote, Pfunc({|event| ~processing.sendMsg("/voice"); }),
		\buf, Pseq([~voice1.bufnum, ~voice2.bufnum, ~voice3.bufnum], inf)
	);

	// Pbindef(\kytar, \amp, 0.5);

	// Pbindef(\voicePattern).play(~vc);

	~voicePlays = false;







	OSCdef.newMatching(\voice, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];


		// Amplituda
		if (amp != amp, {
			Pdefn(\voiceAmp, 0);
			if (~voicePlays==true,{
				Pbindef(\voicePattern).stop;
				~voicePlays = false;
				Pdefn(\voiceAmp, 0);
			});
		}, {
			if (~voicePlays==false, {
				Pbindef(\voicePattern).play(~vc);
				~voicePlays = true;
				Pdefn(\voiceAmp, amp);
			},{
				Pdefn(\voiceAmp, amp);
			});


		} );

		// Pan
		if ( pan != pan, {
			Pdefn(\voicePan, 0);
		},{
			Pdefn(\voicePan, pan);
		} );

		// Height mapuje základní notu na rozsah 60 - 67
		if (h!=h, {},{

			// h.linlin(-1,1, 2, 6).round.asInteger.postln;

			if (h < 0.5,{
				// ~se.set(\bpfQ, h.linlin(0.0, 0.5, 0.3, 5.0) );
			},{
				// ~se.set(\bpfQ, h.linlin(0.5, 1.0, 5.0, 0.3) );
			});

		});

		if (speed!=speed, {
		},{});

		if (pivoty!=pivoty, {},{

			var octave = pivoty.linlin(0.0,1.0, 7, 4).floor.asInteger;

			Pdefn(\voiceOctave, octave);
			// Pdefn(\starmelody, pivoty.linlin(0,1,40,67).round);
		});

		if (pivotx!==pivotx,{},{

			var tempo = pivotx.linlin(0.0,1.0, 0.5, 2);

			Pdefn(\voiceDur, tempo);

		});

	},
	"/voice",
	recvPort: 57133
	);

	OSCdef(\voice).enable;











	~akord = Buffer.read(s, ~path.value( "akord/akord_4_rich_raw.wav" ));

	// a = Synth.new(\sample, [\buf, ~akord.bufnum, \amp, 0.3 ]);

	OSCdef.newMatching(\event, { |msg, time, addr, recvPort|
		var start = msg[1], code = msg[2];

		[start, code].postln;

		if(start == true, {
			"Playing buffered content".postln;
			Pdefn(\master, 0.1);
			Synth.new(\sample, [\buf, ~akord.bufnum, \amp, 0.3 ]);
		},{
			Pdefn(\master, 1);
		});


	},
	"/event",
	recvPort: 57133
	);

	OSCdef(\event).enable;















	OSCdef.newMatching(\phase, { |msg, time, addr, recvPort|
		var code = msg[1];

		"Phase changed".postln;
		// code.postln;

		case {code == 0} {
			Pdefn(\starShift, Pxrand(#[0,1,2,4],inf));
			Pdefn(\kytarShift, Pxrand(#[0,1,2,4],inf));
		}
		{code == 1} {
			Pdefn(\starShift, Pxrand(#[0,0,1,2],inf));
			Pdefn(\kytarShift, Pxrand(#[0,0,1,2],inf));
		}
		{code == 2} {
			Pdefn(\starShift, Pxrand(#[0,0,1],inf));
			Pdefn(\kytarShift, Pxrand(#[0,0,1],inf));
		}
		{code == 3} {
			Pdefn(\starShift, 0);
			Pdefn(\kytarShift, 0);
		};

		~phase = code;

	},
	"/phase",
	recvPort: 57133
	);

	OSCdef(\phase).enable;















	["Started scsynth on", NetAddr.localAddr.hostname, NetAddr.langPort].postln;

    // Debug zpráva
    "SynthDef s ADSR obálkou byl úspěšně nahrán a Synth spuštěn!".postln;




    // s.plotTree;
    // s.meter;

});


)


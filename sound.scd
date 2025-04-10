// Spuštění zvukového serveru
s = Server.default;
s.boot; // Spuštění zvukového serveru

s.quit;

Server.local.options.device = "Built-in Audio";
Server.internal.options.device = "Built-in Audio";

s.options.outDevice;



(
// Počkejte, dokud není server připraven
s.waitForBoot({




	n = NetAddr.new( NetAddr.localAddr.hostname, 57133 );

	~processing = NetAddr.new( NetAddr.localAddr.hostname, 7772 );







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


	// Počkejte, dokud není SynthDef nahrán
    s.sync;


	~phase = 0;





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


	Pbindef(\test,
		\instrument, \sample,
		\dur, Pdefn(\starDur),
		\degree, Pdefn(\starDegree).asStream.next(1),
		\scale, Pdefn(\starScale),
		\octave, Pdefn(\starOctave),
		\amp, Pdefn(\starAmp),
		\pan, Pdefn(\starPan),
		\out, 0,
		\onNote, Pfunc({|event| ~processing.sendMsg("/bell"); })
	);

	Pbindef(\test).play(~sc);






    OSCdef.newMatching(\bell, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];


		// Amplituda
		if (amp != amp, {
			Pdefn(\starAmp, 0);
		}, {
			Pdefn(\starAmp, amp);
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
	Pdefn(\kytarMelody, Pseq([0, 1, 2, 3, 4, 0, 0], inf));
	Pdefn(\kytarShift, Pxrand(#[0,1,2],inf));
	Pdefn(\kytarPan, 0);
	Pdefn(\kytarAmp, 0);
	Pdefn(\kytarScale, Scale.minorPentatonic);
	Pdefn(\kytarOctave, 4);

	// Konvertor stupňů
	Pdefn(\kytarDegree,
		Pfuncn({
			Pdefn(\kytarMelody) + Pdefn(\kytarShift)
		}, inf)
	);


	Pbindef(\kytar,
		\instrument, \sample,
		\dur, Pdefn(\kytarDur),
		\degree, Pdefn(\kytarDegree).asStream.next(1),
		\scale, Pdefn(\kytarScale),
		\octave, Pdefn(\kytarOctave),
		\amp, Pdefn(\kytarAmp),
		\pan, Pdefn(\kytarPan),
		\out, 0,
		\onNote, Pfunc({|event| ~processing.sendMsg("/kytar"); }),
		\buf, ~kytar.bufnum
	);

	// Pbindef(\kytar, \amp, 0.5);

	Pbindef(\kytar).play(~kc);






    OSCdef.newMatching(\kytar, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];


		// Amplituda
		if (amp != amp, {
			Pdefn(\kytarAmp, 0);
		}, {
			Pdefn(\kytarAmp, amp);
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














	v = Bus.control(s, 1); // Speed amount 0-1
	h = Bus.control(s, 1); // Current height 0-1

	m = Bus.control(s, 1); // Minimal frequency
	n = Bus.control(s, 1); // Maximal frequency

	v.set(0);
	h.set(0);
	m.set(0);
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

	~data = List.new(100).addAll(Array.fill(100, 0));  // Seznam na data (max 100 bodů)
    // Vytvoříme okno a kreslící plochu
    w = Window("OSC Graph", Rect(100, 100, 500, 300)).front;
    u = UserView(w, Rect(0, 0, 500, 300))
        .background_(Color.black)
        .drawFunc_({
            Pen.color = Color.green;
            Pen.width = 2;
            Pen.moveTo(Point(0, u.bounds.height / 2)); // Start ve středu Y
            ~data.do { |val, i|
                Pen.lineTo(Point(i * (u.bounds.width / ~data.size),
                    (u.bounds.height / 2) - (val * 100))); // Škálování
            };
            Pen.stroke;
        });





	//OSCdef(\saber).disable;






















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




    s.plotTree;
    s.meter;

});


)


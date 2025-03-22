// Spuštění zvukového serveru
s = Server.default;
s.boot; // Spuštění zvukového serveru



(
// Počkejte, dokud není server připraven
s.waitForBoot({




	n = NetAddr.new( NetAddr.localAddr.hostname, 57133 );







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
	SynthDef.new(
		\sample, {
			arg amp=1, pan=0, out=0, buf, rate=1, base=60, target=60, range=0, shift=0; // targetNote je ve formátu MIDI čísla
			var sig, freqRatio, randomNoteDifference;

			range = range.ceil;

			randomNoteDifference = Rand(range * - 1,range).round;

			// Vypočítáme frekvenční poměr mezi původní notou samplu a požadovanou notou
			freqRatio = 2 ** ((target - base + randomNoteDifference + shift) / 12); // Výpočet frekvenčního poměru

			// Přehrávání bufferu s nastaveným posunem frekvence
			sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate * freqRatio, doneAction: 2);
			sig = Pan2.ar(sig, pan);
			sig = sig * amp;
			Out.ar(out, sig);
		}
	).add;


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
	~se.set(\bpfFreq, 1000);
	// Clock
	~sc = TempoClock.new(1.0);
	~sc.tempo = 2;

	// Intervaly na změnu melodie
	~sinterval = 5.0;
	~slast = 0;


	// Proměnné

	Pdefn(\stardiff, 0); // Výchozí deviace
	// Pdefn(\stardiff, 4);

	Pdefn(\starbase, 60); // Základní nota

	Pdefn(\starmelody, 60); // Nosná melodie
	// Pdefn(\starmelody, Pseq([60, 61, 62, 63, 64, 65, 66, 67], inf));
	// Pdefn(\starmelody, Pseq([62, 65, 67, 69 ], inf));

	Pdefn(\stardur, Pseq([1, 1, 1, 1], inf)); // Ve výchozím stavu hraje po 4 taktech

	Pdefn(\starshift, Pseq([0, 0, -2, 3, 0, 0, -2, -5], inf)); // Výchozí relativní melodie
	// Pdefn(\starshift, Pseq([0, -3, 0, 1], inf));
	// Pdefn(\starshift, Pseq([0, 0, -2, 3], inf));
	// Pdefn(\starshift, Pseq([0, 0, -2, 3, 0, 0, -2, -5], inf));
	// Pdefn(\starshift, Pseq([0, -1, 1, -2], inf));
	// Pdefn(\starshift, 0);


	Pbindef(\star,
		\instrument, \sample,
		\dur, Pdefn(\stardur),
		\buf, ~s1.bufnum,
		\base, Pdefn(\starbase),
		\range, Pdefn(\stardiff),
		\target, Pdefn(\starmelody),
		\shift, Pdefn(\starshift),
		\amp, 0,
		\atk, 0.1,
		\pan, 0,
		\out, ~sb
	);

	Pbindef(\star).play(~sc);
	Pbindef(\star).stop;

	Pbindef(\star, \amp, 1);

	Pdefn(\starshift, Pseq([0, 5, 8, 7, 5, 12, 10, 7 ], inf));

	Pdefn(\starshift, Pseq([-2, 8, 7 ], inf));







    OSCdef.newMatching(\bell, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];



		// msg.postln;

		// Amplituda
		if (amp != amp, {
			Pbindef(\star, \amp, 0 );
			Pbindef(\star).stop;
		}, {
			Pbindef(\star, \amp, amp );
			Pbindef(\star).play(~sc);
		} );

		// Pan
		if ( pan != pan, {
			Pbindef(\star, \pan, 0 );
		},{
			Pbindef(\star, \amp, pan );
		} );

		// Height mapuje základní notu na rozsah 60 - 67
		if (h!=h, {},{

			if (h < 0.5,{
				~se.set(\bpfQ, h.linlin(0.0, 0.5, 0.3, 5.0) );
			},{
				~se.set(\bpfQ, h.linlin(0.5, 1.0, 5.0, 0.3) );
			});



		});

		if (speed!=speed, {
			~sc.tempo = 4;
		},{

		});

		if (pivoty!=pivoty, {},{
			Pdefn(\starmelody, pivoty.linlin(0,1,40,67).round);
		});

		if (pivotx!==pivotx,{},{

			var now = SystemClock.seconds;

			if ( (now - ~slast) > ~sinterval, {
				/*
				~slast = now;
				case
				{ pivotx < 0.25 } { Pdefn(\starshift, Pseq([0, -3, 0, 1], inf)); 1.postln }
				{ pivotx >= 0.25 && pivotx < 0.5 } { Pdefn(\starshift, Pseq([0, 0, -2, 3, 0, 0, -2, -5], inf)); 2.postln; }
				{ pivotx >= 0.5 && pivotx < 0.75} { Pdefn(\starshift, Pseq([0, 0, -2, 3], inf)); 3.postln; }
				{ pivotx>= 0.75 && pivotx < 1 } { Pdefn(\starshift, 0); 4.postln; };
				*/
			},{

			} );


		});

	},
	"/bell",
	recvPort: 57133
	);

	OSCdef(\bell).enable;















	/**
	 * Stars
	 */

	// Samply
	~k1 = Buffer.read(s, ~path.value( "string/string_cut.aiff" ));
	// Bus
	~kb = Bus.audio(s, 2);
	// Effector
	~ke = Synth.new(\effector, [\in, ~kb]);
	~ke.set(\bpfFreq, 300);
	// Clock
	~kc = TempoClock.new(1.0);
	~kc.tempo = 1;

	// Intervaly na změnu melodie
	~kinterval = 5.0;
	~klast = 0;


	// Proměnné

	Pdefn(\kdiff, 0); // Výchozí deviace
	// Pdefn(\kdiff, 4);

	Pdefn(\kbase, 60); // Základní nota

	Pdefn(\kmelody, 52); // Nosná melodie
	// Pdefn(\kmelody, Pseq([60, 61, 62, 63, 64, 65, 66, 67], inf));
	// Pdefn(\kmelody, Pseq([62, 65, 67, 69 ], inf));

	Pdefn(\kdur, 1); // Ve výchozím stavu hraje po 1 taktu
	// Pdefn(\kdur, Pseq([1, 1, 1, 3], inf));

	Pdefn(\kshift, Pseq([0, 0, -2, 3, 0, 0, -2, -5], inf)); // Výchozí relativní melodie
	// Pdefn(\kshift, Pseq([0, -3, 0, 1], inf));
	// Pdefn(\kshift, Pseq([0, 0, -2, 3], inf));
	// Pdefn(\kshift, Pseq([0, 0, -2, 3, 0, 0, -2, -5], inf));
	// Pdefn(\kshift, Pseq([0, -1, 1, -2], inf));
	// Pdefn(\kshift, 0);


	Pbindef(\kytar,
		\instrument, \sample,
		\dur, Pdefn(\kdur),
		\buf, ~k1.bufnum,
		\base, Pdefn(\kbase),
		\range, Pdefn(\kdiff),
		\rate, 0.5,
		\target, Pdefn(\kmelody),
		\shift, Pdefn(\kshift),
		\amp, 0,
		\atk, 0.1,
		\pan, 0,
		\out, ~kb
	);

	Pbindef(\kytar).play(~kc);
	// Pbindef(\kytar).stop;







    OSCdef.newMatching(\kytarlistener, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];



		// msg.postln;

		// Amplituda
		if (amp != amp, {
			Pbindef(\kytar, \amp, 0 );
			Pbindef(\kytar).stop;
		}, {
			if(amp ==0, {
				Pbindef(\kytar, \amp, 0 );
				Pbindef(\kytar).stop;
			},{
				Pbindef(\kytar, \amp, amp.linlin(0,1,0.2,1.2) );
				Pbindef(\kytar).play(~kc);
			});

		} );

		// Pan
		if ( pan != pan, {
			Pbindef(\kytar, \pan, 0 );
		},{
			Pbindef(\kytar, \amp, pan );
		} );

		// Height mapuje základní notu na rozsah 60 - 67
		if (h!=h, {},{

			if (h < 0.5,{
				~ke.set(\bpfQ, h.linlin(0.0, 0.5, 0.1, 2.0) );
			},{
				~ke.set(\bpfQ, h.linlin(0.5, 1.0, 2.0, 0.1) );
			});



		});

		if (speed!=speed, {
			//~kc.tempo = 4;
		},{

		});

		if (pivoty!=pivoty, {},{
			Pdefn(\kmelody, pivoty.linlin(0,1,40,67).round);
		});

		if (pivotx!==pivotx,{},{

			var now = SystemClock.seconds;

			if ( (now - ~klast) > ~kinterval, {
				~klast = now;
				case
				{ pivotx < 0.25 } { Pdefn(\kshift, Pseq([0, -3, 0, 1], inf)); }
				{ pivotx >= 0.25 && pivotx < 0.5 } { Pdefn(\kshift, Pseq([0, 0, -2, 3, 0, 0, -2, -5], inf)); }
				{ pivotx >= 0.5 && pivotx < 0.75} { Pdefn(\kshift, Pseq([0, 0, -2, 3], inf)); }
				{ pivotx>= 0.75 && pivotx < 1 } { Pdefn(\kshift, 0); };
			},{

			} );


		});

	},
	"/kytar",
	recvPort: 57133
	);

	OSCdef(\kytarListener).enable;












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



	OSCdef.newMatching(\saber, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], height = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6], particleSpeed=msg[7];

		// msg[0].postln;



		// msg.postln;

		// Amplituda
		if (amp != amp, {
			Ndef(\saber).set(\amp, 0);
		}, {
			Ndef(\saber).set(\amp, amp);
			// Pbindef(\kytar, \amp, amp.linlin(0,1,0.2,1.2) );
			//Pbindef(\kytar).play(~kc);
		} );

		// Pan
		if ( pivotx != pivotx, {
			Ndef(\saber).set(\pan, 0);
		},{
			Ndef(\saber).set(\pan, pivotx.linlin(0,1, -1, 1));
		} );

		// Height mapuje základní notu na rozsah 60 - 67
		if (height!=height, {
			h.set(0.5);
		},{

			h.set(height);

		});

		// particleSpeed.postln;

		pivotx.postln;
		{
		~data.add(speed);
            if (~data.size > 100, { ~data.removeAt(0) }); // Max 100 bodů
            u.refresh; // Překreslíme graf
		}.defer;

		if (speed!=speed, {
			//~kc.tempo = 4;
			v.set(0);
			Ndef(\saber).set(\speed, 1.5);
		},{
			v.set(speed);
			Ndef(\saber).set(\speed, speed.linlin(0,1, 1.5, 2.5));
		});

		if (pivoty!=pivoty, {},{
			// Pdefn(\kmelody, pivoty.linlin(0,1,40,67).round);
		});

		if (pivotx!==pivotx,{},{


		});

	},
	"/saber",
	recvPort: 57133
	);

	OSCdef(\saber).enable;

	//OSCdef(\saber).disable;






















	OSCdef.newMatching(\phase, { |msg, time, addr, recvPort|
		var code = msg[1];

		"Phase changed".postln;
		// code.postln;

		case {code == 0} {
			Pdefn(\stardiff, 20);
		}
		{code == 1} {
			Pdefn(\stardiff, 5);
		}
		{code == 2} {
			Pdefn(\stardiff, 1);
		}
		{code == 3} {
			Pdefn(\stardiff, 0);
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


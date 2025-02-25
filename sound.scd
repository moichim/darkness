// Spuštění zvukového serveru
s = Server.default;
s.boot; // Spuštění zvukového serveru

(
// Počkejte, dokud není server připraven
s.waitForBoot({




	n = NetAddr.new( NetAddr.localAddr.hostname, NetAddr.localAddr.port );







	/**
	 * Globální věci
	 */

	// Přehrání bufferu
	SynthDef.new(
		\playbuff, {
			arg amp=1,pan=0,out=0,buf,rate=1,bpFreq=1000, rq=0.5;
			var sig;
			sig = PlayBuf.ar(1,buf, BufRateScale.kr(buf) * rate,doneAction:2);
			sig = BPF.ar(sig, bpFreq, rq);
			sig = Pan2.ar(sig,pan);
			sig = sig * amp;
			Out.ar( out, sig );
		}
	).add;


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




	// Synthdef A
	SynthDef(\a, { arg i_out, freq = 360, gate = 1, pan, amp=0.1, lagf=0.2, lagp=0.2;
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




	// Basový synthdef
	SynthDef.new(
		\base,{
			arg freq=300, freqLow=60,atk=0.1,rel=2,pan=0, amp=1;
			var sig, sigMain, sigLow, envMain, envLow;
			envMain = EnvGen.ar(Env.perc(atk,rel));
			envLow = EnvGen.ar(Env.perc(atk,rel*2));
			sigMain = SinOsc.ar(freq,0.5) *  envMain;
			sigLow = SinOsc.ar(freqLow,0.75) * envLow;
			sig = sigMain + sigLow;
			sig = Pan2.ar(sig,pan);
			sig = sig * amp;
			Out.ar(0,sig);
		}
	).add;




	// Počkejte, dokud není SynthDef nahrán
    s.sync;





























	/**
	 * A - plyunlý zvuk
	 */



	// Globální proměnné A
	~a = Synth.new(\a, [\freq, 20, \amp, 0]);


	// Routa A
    OSCdef.newMatching(\a, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4];

		[msg, time, addr, recvPort].postln;


		// Amplituda
		if (amp != amp, {
			~a.set(\amp, 0, \lagp, 3, \freq, 20, \lagf, 2);
		}, {
			~a.set(\amp, amp, \lagp, 0.2);
		} );

		// Pan
		if ( pan != pan, {
			~a.set( \pan, 0 );
		},{
			~a.set( \pan, pan );
		} );

		if (speed!=speed, {},{
			// ~a.set( \freq, speed.linlin(1,10,20,100), \lagf, 0.1 );
		});

		if (h!=h, {},{
			~a.set( \freqLow, h.linlin(0,1,20,100), \lagf, 0.1 );
		});


		//~x.set(\freq, freq, \amp, amp, \pan, pan);

	},
	"/a",
	);


	OSCdef(\a).enable;




	/**
	 * B
	 */

	// Načtení samplů
	~b1 = Buffer.read(s, "/Users/moichim/Documents/GitHub/darkness/samples/1_nastroje/stars/rev/star_1.aiff");
	~b2 = Buffer.read(s, "/Users/moichim/Documents/GitHub/darkness/samples/1_nastroje/stars/rev/star_2.aiff");
	~b3 = Buffer.read(s, "/Users/moichim/Documents/GitHub/darkness/samples/1_nastroje/stars/rev/star_3.aiff");

	Pdefn(\bdur, 0.5);


	// Definice vzorku
	Pdef.new(
		\b,
		Pbind(
			\instrument, \playbuf,
			\dur, Pdefn(\bdur),
			\buf, Pseq([~b1.bufnum, ~b2.bufnum, ~b3.bufnum], inf),

		)
	);

	Pdef(\b).set(\amp, 0);

	Pdef(\b).play;



	// Routa A
    OSCdef.newMatching(\b, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4];

		amp.postln;

		// Amplituda
		if (amp != amp, {
			//Pdef(\b).set(\amp, 0);
		}, {
			Pdef(\b).set(\amp, amp);
		} );

		// Pan
		if ( pan != pan, {
			Pdef(\b).set(\pan, 0);
		},{
			Pdef(\b).set(\pan, pan);
		} );

		if (h!=h, {},{
			Pdef(\b).set(\rate, h.linlin(0, 1, 0.1, 0.5 ));

			if ( h > 0.5, {
				Pdef(\b).set(\buf, Pseq([~b1.bufnum, ~b1.bufnum, ~b1.bufnum, ~b2.bufnum], inf));
			}, {
					Pdef(\b).set(\buf, Pseq([~b1.bufnum, ~b2.bufnum, ~b2.bufnum], inf));
			});

		});

		if (speed!=speed, {},{
			Pdefn(
				\bdur, speed.linlin( 0, 2, 0.5, 0.1 ),
			);
		});


		//~x.set(\freq, freq, \amp, amp, \pan, pan);
		[msg, time, addr, recvPort].postln;
	},
	"/b",
	);


	OSCdef(\b).enable;
		// OSCdef(\b).disable;




//"/Users/moichim/Documents/GitHub/darkness/samples/1_nastroje/stars/rev/star_1.aiff"


	~s1 = Buffer.read(s, "/Users/moichim/Documents/GitHub/darkness/samples/1_nastroje/strings/rev/string_cut.aiff" );

		// Synth.new(\playbuf, [\buf, ~s1.bufnum]);


		/**
	 * B
	 */

	// Načtení samplů


	Pdefn(\cdur, 0.5);


	// Definice vzorku
	Pdef.new(
		\c,
		Pbind(
			\instrument, \playbuf,
			\dur, Pdefn(\cdur),
			\buf, ~s1.bufnum,
			//\rate, Prand([1,0.5,0.75,1,1,2], inf)
		)
	);

	Pdef(\c).set(\amp, 0);
	Pdef(\c).set(\rate, Pxrand(#[1, 0.5, 0.75, 1, 1, 2 ], inf));
	Pdef(\c).set(\rate, 0.7);

	Pdef(\c).play;



	// Routa c
    OSCdef.newMatching(\c, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4];

		amp.postln;

		// Amplituda
		if (amp != amp, {
			//Pdef(\c).set(\amp, 0);
		}, {
			Pdef(\c).set(\amp, amp);
		} );

		// Pan
		if ( pan != pan, {
			Pdef(\c).set(\pan, 0);
		},{
			Pdef(\c).set(\pan, pan);
		} );

		if (h!=h, {},{
			Pdef(\c).set(\rate, h.linlin(0, 1, 0.1, 0.1 ));

			if ( h > 0.5, {
				// Pdef(\c).set(\buf, Pseq([~b1.bufnum, ~b1.bufnum, ~b1.bufnum, ~b2.bufnum], inf);
			}, {
				// Pdef(\c).set(\buf, Pseq([~b1.bufnum, ~b2.bufnum, ~b2.bufnum], inf);
			});

		});

		if (speed!=speed, {},{
			Pdefn(
				\cdur, speed.linlin( 0, 5, 0.5, 0.1 ),
			);
		});


		//~x.set(\freq, freq, \amp, amp, \pan, pan);
		[msg, time, addr, recvPort].postln;
	},
	"/c",
	);


	OSCdef(\c).enable;

























	// Bass synths reciever
	// Routa A
    OSCdef.newMatching(\base, { |msg, time, addr, recvPort|
		var freq = msg[1];

		x = Synth.new(\base, [\freq, freq, \freqLow, 70, \atk, 0.5]);



		//~x.set(\freq, freq, \amp, amp, \pan, pan);
		[freq].postln;
	},
	"/bass",
	);


	OSCdef(\base).enable;























	["Started scsynth on", NetAddr.localAddr.hostname, NetAddr.langPort].postln;

    // Debug zpráva
    "SynthDef s ADSR obálkou byl úspěšně nahrán a Synth spuštěn!".postln;




    s.plotTree;
    s.meter;

});
)


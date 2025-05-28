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


	Pdefn( \master, 0.5 );

	~in = 57133;
	~out = 47120;




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
	SynthDef(\sampler, {
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

	Pdefn(\master, 1);





	// Stars
	~s1 = Buffer.read(s, ~path.value( "star/star_1.aiff" ));
	~s2 = Buffer.read(s, ~path.value( "star/star_2.aiff" ));
	~s3 = Buffer.read(s, ~path.value( "star/star_3.aiff" ));

	~bell = DarknessTool.new("bell", ~in, ~out);
	~bell.setBuf( ~s1.bufnum );
	~bell
	.setOctave(6)
	// .setAmp(0)
	.setMelody( Pseq([0, 1, 2, 3, 4, 0, 0], inf) )
	.setDur(0.5)
	.setScale(Scale.minorPentatonic)
	.setOctaveRange(2,6);

	~bell.listen;










	// Kytara

	~k1 = Buffer.read(s, ~path.value( "string/string_cut.aiff" ));

	~kytar = DarknessTool("kytar",~in,~out);
	~kytar
	.setBuf(~k1.bufnum)
	.setOctave(4)
	.setMelody(Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf))
	.setDur(1)
	.setShift(Pxrand(#[0,1,2],inf));

	~kytar.listen;

	~kytar.setOctave(8);
	~kytar.setOctaveRange(2,8);










	~drum = Buffer.read(s, ~path.value( "drum/bassdrum02.ogg" ));
	~ding = Buffer.read(s, ~path.value( "ding/dong02.ogg" ));



	// Piano

	~p1 = Buffer.read(s, ~path.value( "piano/c.wav" ));

	~piano = DarknessTool.new("piano", ~in, ~out);
	~piano
	.setDur(1)
	.setMelody(Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf))
	.setShift(Pxrand(#[0,1,2],inf))
	.setOctaveRange(4,8)
	.setOctave(6)
	.setBuf(~drum.bufnum);

	~piano.listen;
















	// Voice

	~voice1 = Buffer.read(s, ~path.value( "voice/07_c2_rev_1.aiff" ));
	~voice2 = Buffer.read(s, ~path.value( "voice/07_c2_rev_2.aiff" ));
	~voice3 = Buffer.read(s, ~path.value( "voice/07_c2_rev_3.aiff" ));

	~voice = DarknessTool.new("voice", ~in, ~out );
	~voice
	.setDur(1)
	.setOctave(6)
	.setOctaveRange(4,7)
	.setMelody(Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf))
	.setShift(Pxrand(#[0,1,2],inf))
	.setBuf(Pseq([~voice1.bufnum, ~voice2.bufnum, ~voice3.bufnum], inf));

	~voice.listen;





	~akord = Buffer.read(s, ~path.value( "akord/akord_4_rich_raw.wav" ));


	~control = DarknessControl.new;
	~control
	.addTool( ~bell )
	.addTool( ~kytar )
	.addTool( ~piano )
	.addTool( ~voice );

	~control.addSample(\akord, ~akord);

	~control.addEvent(\acordEvent, SoundEvent.new({
		"started".postln;
		Pdefn(\master, 0.5);
		~control.playSample( \akord, 0.3 );
	},{
		Pdefn(\master, 1);
	}));

	~control.addEvent(\vinetou, SoundEvent.new({

		~bell.setMelody( Pseq([0,2,4,6,8], inf) );
		~kytar.setMelody( Pseq([8, 6, 4, 2, 0], inf) );
		~voice.setMelody( Pseq([1,3,7,2,8], inf) );
		~piano.setMelody( Pseq([7,3,0,1], inf) );
		~control.setTempoToggling(1);

	},{
		~control.setTempoNormal();
	}));

	~mantraOne = SoundMelody.new();
	~mantraOneMelody = Pseq([0, 2, 5, 8], inf);
	~mantraOne.addLine(~kytar,
		melody: ~mantraOneMelody,
		dur: 1,
		octave: 5
	);
	~mantraOne.addLine(~bell,
		melody: ~mantraOneMelody,
		dur: 0.5,
		octave: 5
	);
	~mantraOne.addLine(~voice,
		melody: ~mantraOneMelody,
		dur: 1,
		octave: 5
	);


	~mantraTwo = SoundMelody.new();
	~mantraTwoMelody = Pseq([0, 5, 2, 3], inf);
	~mantraTwo.addLine(~kytar,
		melody: ~mantraTwoMelody,
		dur: 1,
		octave: 5
	);
	~mantraTwo.addLine(~bell,
		melody: ~mantraTwoMelody,
		dur: 0.5,
		octave: 5
	);
	~mantraTwo.addLine(~voice,
		melody: ~mantraTwoMelody,
		dur: 1,
		octave: 5
	);

	~mantraThree = SoundMelody.new();
	~mantraThreeMelody = Pseq([0, 5, 2, 8], inf);
	~mantraThree.addLine(~kytar,
		melody: ~mantraTwoMelody,
		dur: 1,
		octave: 5
	);
	~mantraThree.addLine(~bell,
		melody: Pseq( [0, 5, 2, 8, 2, 5, 0], inf ),
		dur: 0.5,
		octave: 5
	);
	~mantraThree.addLine(~voice,
		melody: ~mantraThreeMelody,
		dur: 1,
		octave: 5
	);

	~mantraFour = SoundMelody.new();
	~mantraFourMelody = Pseq([0, 5, 2, 8], inf);
	~mantraFour.addLine(~kytar,
		melody: ~mantraFourMelody,
		dur: Pseq([1,1,1,3], inf),
		octave: 5
	);
	~mantraFour.addLine(~bell,
		melody: Pseq( [0, 5, 2, 8, 2, 5, 0], inf ),
		dur: Pseq([2, Pseq([0.5],4),1,1], inf),
		octave: 5
	);
	~mantraFour.addLine(~voice,
		melody: ~mantraFourMelody,
		dur: Pseq([1,1,0.5, 0.5,3], inf),
		octave: 5
	);

	~mantraFive = SoundMelody.new();
	~mantraFive.addLine(~kytar,
		melody: Pseq( [0, 2, 8, 4, 6, 2, 0], inf ),
		dur: Pseq([Pseq([0.5],7),2], inf),
		octave: 5
	);
	~mantraFive.addLine(~bell,
		melody: Pseq([0, 0, 2, 5, 1], inf),
		dur: Pseq([3, Pseq([0.5],4),1,1], inf),
		octave: 5
	);
	~mantraFive.addLine(~voice,
		melody: Pseq([0, 1, 2, 3, 4, 5], inf),
		dur: Pseq([1,1,0.5, 0.5,3], inf),
		octave: 5
	);

	~mantraSix = SoundMelody.new();
	~mantraSix.addLine(~kytar,
		melody: Pseq( [4, 0, 5, 1, 2, 0], inf ),
		dur: Pseq([Pseq([0.5],6),3], inf),
		octave: 5
	);
	~mantraSix.addLine(~bell,
		melody: Pseq([5, 5, 2, 5, 0, 0], inf),
		dur: Pseq([3, Pseq([0.5],6)], inf),
		octave: 5
	);
	~mantraSix.addLine(~voice,
		melody: Pseq([0, 1, 2, 3, 4, 5], inf),
		dur: Pseq([1,Pseq([0.5], 4),2], inf),
		octave: 5
	);

	~mantraSeven = SoundMelody.new();
	~mantraSeven.addLine(~kytar,
		melody: Pseq( [0, 0, 3, 3, 5, 5, Pxrand([2, 0], 1)], inf ),
		dur: Pseq([Pseq([0.5],6),1], inf),
		octave: 5
	);
	~mantraSeven.addLine(~bell,
		melody: Pseq([5, 5, 3, 3, 0, 0, 1], inf),
		dur: 1,
		octave: 5
	);
	~mantraSeven.addLine(~voice,
		melody: Pseq([0, 1, 2, 3, 4, 5], inf),
		dur: Pseq([1,Pseq([0.5], 4),2], inf),
		octave: 5
	);

	/*

	~main = Pseq( [0, 0, 3, 3, 5, 5, Pxrand([2, 0], 1)], inf );


	~kytar.setMelody(~main);
	~kytar.setOctave(5);
	~kytar.setShift(0);
	~kytar.setPan(0);
	~kytar.setDur(Pseq([Pseq([0.5],6),1], inf));

	~bell.setMelody(Pseq([5, 5, 3, 3, 0, 0, 1], inf));
	~bell.setOctave(5);
	~bell.setShift(0);
	~bell.setPan(0);
	~bell.setDur(0.5);
	~bell.setDur(Pseq([1], inf));

	~voice.setMelody(Pseq([0, 1, 2, 3, 4, 5], inf));
	~voice.setOctave(5);
	~voice.setPan(0);
	~voice.setShift(0);
	~voice.setDur(1);
	~voice.setDur(Pseq([1,Pseq([0.5], 4),2], inf));

	// ~piano.play;
	~voice.play;
	~bell.play;
	~kytar.play;

	~kytar.stop;
	~bell.stop;
	~voice.stop;

	*/



	Pdefn(\master, 0.25);

	~control.addMelody( \mantraOne, ~mantraOne );
	~control.addMelody( \mantraTwo, ~mantraTwo );
	~control.addMelody( \mantraThree, ~mantraThree );
	~control.addMelody( \mantraFour, ~mantraFour );
	~control.addMelody( \mantraFive, ~mantraFive );
	~control.addMelody( \mantraSix, ~mantraSix );
	~control.addMelody( \mantraSeven, ~mantraSeven );







	// a = Synth.new(\sample, [\buf, ~akord.bufnum, \amp, 0.3 ]);

	OSCdef.newMatching(\event, { |msg, time, addr, recvPort|
		var start = msg[1], code = msg[2];

		[start, code].postln;

		if(start == true, {
			"Playing buffered content".postln;

			code.switch(
				1, { ~control.playEvent(\acordEvent); },
				2, { ~control.playEvent(\vinetou) },
				3, { ~control.playMelody(\mantraFour) },
				4, { ~control.playMelody(\matraFive) }
			);

		},{
			Pdefn(\master, 1);
			~control.endEvent();
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


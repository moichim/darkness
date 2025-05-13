// Spuštění zvukového serveru
s = Server.default;
// ; // Spuštění zvukového serveru

// s.quit;

// Server.local.options.device = "Aggr";
// Server.internal.options.device = "Aggr";
// s.options.sampleRate = 48000;

// s.options.outDevice;

Pdefn( \master, 0.5 );

~test = DarknessTool.new("bell", 57133, 47120);

// ~test.setAmp(2).setPan(-100).setBuf(~s2.bufnum).setOctave(3).setMelody(Pseq([0,1,2,3,4], inf)).setShift(0).setOctave(Scale.minorPentatonic).setDur(2);

~test.init;

~test.play;
~test.stop;
~test.listen;

~test.setDur(0.5);
~test.setAmp(0.02);
~test.setPan(1);
~test.setMelody(4);
~test.setShift(0);
~test.setOctave(5);

Pdefn( ~test.pan, 2 );

Pbindef( ~test.pattern ).gui(10);

~test.pbind.stop;

Pbindef(~test.pattern);

~bell.play;
~bell.stop;
~bell.setMelody( Pseq([0, 1, 3, 5, 4, 2], inf) );
~bell.setAmp(0.5);
~bell.setPan( Pseq([-1,1], inf) );
~bell.setOctave(5);
~bell.setOctaveRange( 3, 10 );
~bell.setScale( Scale.minorPentatonic );
~bell.setShift(0);

~bell.mute;

~kytar.play;
~kytar.stop;
~kytar.setAmp(0.5);
~kytar.setShift(0);
~kytar.setMelody(Pseq([0, 1, 3, 5, 4, 2], inf));
(
~bell.play;
~kytar.play;
)

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










	~drum = Buffer.read(s, ~path.value( "drum/bassdrum02.ogg" ));
	~ding = Buffer.read(s, ~path.value( "ding/dong02.ogg" ));



	// Piano

	~p1 = Buffer.read(s, ~path.value( "piano/c.wav" ));

	~piano = DarknessTool.new("piano", ~in, ~out);
	~piano
	.setDur(1)
	.setMelody(Pseq([0, 2, 4, 4, 5, 6, 3, 2, 1, 0],inf))
	.setShift(Pxrand(#[0,1,2],inf))
	.setOctave(4)
	.setBuf(~p1.bufnum);

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

	// a = Synth.new(\sample, [\buf, ~akord.bufnum, \amp, 0.3 ]);

	OSCdef.newMatching(\event, { |msg, time, addr, recvPort|
		var start = msg[1], code = msg[2];

		[start, code].postln;

		if(start == true, {
			"Playing buffered content".postln;
			Pdefn(\master, 0.5);
			Synth.new(\sampler, [\buf, ~akord.bufnum, \amp, 0.3 ]);
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


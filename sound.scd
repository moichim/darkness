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


	Pdefn( \master, 1 );

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
		arg amp = 1, pan = 0, out = 0, buf, rate = 1, freq = 440, bpfFreq=0, bpfQ = 0.707;
		var sig, playbackRate;

		// Přepočet frekvence na playbackRate vůči základní frekvenci samplu
		// Předpokládáme, že sample je nahrán s výškou A4 (MIDI 69 = 440 Hz)
		playbackRate = freq / 440;

		sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate * playbackRate, doneAction: 2);

	  	sig = Select.ar( bpfFreq > 5.0, [
			sig,
			BPF.ar( sig, bpfFreq, bpfQ )
		] );


		sig = Pan2.ar(sig, pan);
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;


	/** Effector pro každou stopu */
	SynthDef.new(
		\effector, {
			arg in, out=0, bpfFreq=1000, bpfQ=0.707;
			var signal;
			signal = In.ar(in, 2);
			signal = BPF.ar(signal, bpfFreq, bpfQ);
			Out.ar(out, signal);
		}
	).add;


	SynthDef(\beatLayered, {
		|out = 0, freq = 440, depthStart = 3, depthEnd = 1.5,
		atk = 0.01, sus = 0.1, rel = 0.2, amp = 0.5,
		vibRate = 6, vibDepth = 0.05,
		beatFreqRatio = 0.5, beatAmp = 0.4, beatRel = 0.08, pan = 0|

		var freqStart, freqEnd, freqEnv, ampEnv, vibrato, mainOsc, mainAmp, secondaryAmp;
		var beatEnv, beatOsc, sig;

		secondaryAmp = amp.min(1).max(0) * beatAmp.min(1).max(0);
		mainAmp = amp - secondaryAmp;


		freqStart = freq / depthStart;
		freqEnd = freq / depthEnd;

		// Frekvenční obálka
		freqEnv = EnvGen.kr(
			Env([freqStart, freq, freqEnd], [atk, sus, rel], ['exp', 'exp'])
		);

		// Vibrato jako relativní odchylka
		vibrato = SinOsc.kr(vibRate).range(-1, 1) * freq * vibDepth;

		// Hlavní sinusovka s frekvenční obálkou a vibratem
		mainOsc = SinOsc.ar(freqEnv + vibrato);

		// Amplitudová obálka
		ampEnv = EnvGen.kr(Env.perc(atk, rel, 1, curve: -4), doneAction: 2);

		// Beatová vrstva – nízká sinusovka s rychlým dozvukem
		beatEnv = EnvGen.kr(Env.perc(0.001, beatRel), levelScale: secondaryAmp * 2);
		beatOsc = SinOsc.ar(freq * beatFreqRatio) * beatEnv;

		// Výstup
		sig = (mainOsc * ampEnv) + beatOsc;

		sig = sig * mainAmp;

		// sig = Limiter.ar( sig, 1, 0.01 );

		// Kompresor: vstup, kontrolní signál, thresh, slopeBelow, slopeAbove, clampTime, relaxTime
		sig = Compander.ar(
			sig,         // vstupní signál
			sig,         // kontrolní signál (self)
			0.5,         // práh (threshold) - kde začne komprese
			1,           // slopeBelow - pod prahem neměníme (1 = žádná změna)
			0.2,         // slopeAbove - nad prahem zeslabíme (0.2 = silná komprese)
			0.01,        // attack (clampTime)
			0.1          // release (relaxTime)
		);

		sig = Pan2.ar( sig, pan );

		Out.ar(out, sig);
	}).add;



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


	// Vokálovitý zvuk: polyfonní VarSaw, formantové filtry, jemný chorus a reverb
	// Andělský vokálový synth s výrazným reverbem a jemným chorusem
	SynthDef(\polyLayeredSynth, {
		|out = 0, freq = 440, amp = 1, atk = 0.15, sus = 0.5, rel = 2.5, pan = 0,
		vibRate = 5, vibDepth = 0.02, depthEnd = 1, beatAmp = 0|

		var sig, ampEnv, dry, chorus, revMix, outEnv;
		var formantFreqs, formantRatios, nFormants, norm;

		var panSpread = 0.05;

		// beatAmp = beatAmp.linlin(-1, 1, 0, 1);

		// Sborový základ: 3 SinOsc s jemným rozladěním
		sig = (
			Pan2.ar( SinOsc.ar(freq), pan - panSpread ) +
			Pan2.ar( SinOsc.ar(freq * 1.005, 0.2pi), pan + panSpread ) +
			Pan2.ar( LinXFade2.ar(
				SinOsc.ar(freq * 0.997, 0.4pi),
				Saw.ar(freq * 0.997, 0.4pi),
				beatAmp
			), pan + LFNoise1.kr(0.2).range(-1 * panSpread, panSpread) )
		) / 3;

		// Hlavní obálka
		ampEnv = EnvGen.kr(
			Env([0, 1.5, 1, 0], [atk, sus, rel], [-4, -4, -4]),
			doneAction: 2
		);
		sig = sig * ampEnv * amp;

		// 5 formantových frekvencí pro bohatší vokál
		formantRatios = [ 0.75, 1, 1.25, 1.5, 2, 2.5, 3]; // např. 1, 5/4, 3/2, 2, 5/2
		formantFreqs = formantRatios.collect { |r| freq * r };
		nFormants = formantFreqs.size;

		// Randomizace Q a frekvence, obálka pouze depthEnd
		dry = Mix.fill(nFormants, { |i|
			var q = 0.18 + LFNoise1.kr(0.5).range(-0.04, 0.04);
			var freqOffset = LFNoise1.kr(0.3).range(-10, 10);
			var freqEnv = EnvGen.kr(
				Env(
				[formantFreqs[i], formantFreqs[i] * depthEnd], // levels
				[atk + sus + rel],                             // times
				-4                                             // curve
			)
			);
			var vibrato = SinOsc.kr(vibRate, 0, vibDepth * formantFreqs[i]);
			BPF.ar(sig, freqEnv + vibrato + freqOffset, q)
		}) / nFormants;

		// Chorus efekt
		chorus = Mix([
			dry,
			DelayC.ar(dry, 0.04, SinOsc.kr(0.23, 0, 0.018, 0.02)),
			DelayC.ar(dry, 0.04, SinOsc.kr(0.17, 0, 0.012, 0.01))
		]) / 3;

		// Výrazný reverb
		revMix = 0.55;
		sig = (chorus * (1 - revMix)); // + (FreeVerb.ar(chorus, 0.98, 0.95, 0.7) * revMix);

		// Výstupní obálka pro plynulé doznění reverbu (delší fade-out)
		outEnv = EnvGen.kr(
			Env([1, 1, 0], [atk + sus + rel, 1.2]), // fade-out 1.2s
			doneAction: 2
		);
		sig = sig * outEnv;


		// Panorama a limiter s výrazným zesílením
		sig = Pan2.ar(sig, pan);

		// Limiter na konci
		sig = Limiter.ar(sig * 8, 0.99);

		Out.ar(out, sig);

	}).add;


	// Počkejte, dokud není SynthDef nahrán
    s.sync;


	~phase = 0;

	Pdefn(\master, 1);





	// Stars
	~s1 = Buffer.read(s, ~path.value( "star/star_1.aiff" ));
	~s2 = Buffer.read(s, ~path.value( "star/star_2.aiff" ));
	~s3 = Buffer.read(s, ~path.value( "star/star_3.aiff" ));

	~bell = DarknessToolSample.new("bell", ~in, ~out);
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

	~kytar = DarknessToolSample.new("kytar",~in,~out);
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

	~piano = DarknessToolSample.new("piano", ~in, ~out);
	~piano
	.setDur(1)
	.setMelody(Pseq([0, 2, 4, 4, 5, 12],inf))
	.setShift(0)
	.setOctaveRange(4,8)
	.setOctave(6)
	.setBuf(~drum.bufnum);

	~piano.setMelody( Pseq([0, 2, 4, 6, 8, 10],inf) );

	~piano.setBpfMapper({|msg|
		var orientation = msg[8], pivotx = msg[5], pivoty=msg[6];
		var freq = 0, q = 0.707, amount = 0.0;

		//q = -2 * (pivotx - 0.5).squared + 0.7;
		q = pivoty.linlin(0, 1, 0.4, 1.0);

		// freq = -2800 * (pivoty - 0.5).squared + 800;
		// freq = pivotx.linlin(0, 1, 1000, 100);
		freq = orientation.linlin(-1, 1, 1000, 80);

		~piano.setBpf(freq, 0.707);

	});


	~piano.listen;






	// Pulse
	~pulse = DarknessToolSynth.new( "pulse", \beatLayered, ~in, ~out );

	~pulse.setMelody( Pseq([0, 4, 2, 6], inf) );
	~pulse.setDur(1);
	~pulse.setShift(0);
	~pulse.setPan(0);
	~pulse.setOctave( 5 );
	~pulse.setAmp( 1 );
	// ~pulse.setMapper

	// ~pulse.setVibDepth( 0.2 );
	// ~pulse.setVibRate( 10 );
	// ~pulse.setBeatAmp( 0.2 );

	~pulse.setOctaveRange( 4, 7 );

	~pulse.setMapper({|amp, pan, h, speed, pivotx, pivoty, orientation|
		~pulse.setVibAmount( orientation.linlin(-1.0, 1.0, 0.1, 10.0) );
		~pulse.setRel( orientation.linlin( -1.0, 1.0, 0.2, 1.0 ) );
		~pulse.setAtk( orientation.linlin( -1.0, 1.0, 0.2, 0.02 ) );
		~pulse.setDepthStart( pivotx.linlin( 0.0, 1.0, 6.0, 2.0 ) );
		~pulse.setDepthEnd( pivoty.linlin( 0.0, 1.0, 1.2, 5.0 ) );
		if (speed.notNil, {
			~pulse.setVibRate( speed.linlin(0.0, 1.0, 10.0, 50.0) );
		},{});
	});

	~pulse;

	~pulse.listen;
	// ~pulse.play;
	~pulse.stop;


	// Pulse
	~angels = DarknessToolSynth.new( "angels", \polyLayeredSynth, ~in, ~out );

	~angels.setMelody( Pseq([0, 2, 4, 7, 10, 8], inf) );
	~angels.setDur(1);
	~angels.setShift(0);
	~angels.setPan(0);
	~angels.setOctave( 5 );
	~angels.setAmp( 1 );

	~angels.setDepthStart(Pseq([3, 2, 1.5], inf)); // Depth start
	~angels.setDepthEnd(Pseq([1.5, 2, 3], inf)); // Depth end
	~angels.setVibRate(Pseq([4, 6, 8], inf)); // Vibrato rate
	~angels.setVibDepth(Pseq([0.05, 0.1, 0.15], inf)); // Vibrato depth
	~angels.setBeatAmp(Pseq([0.4, 0.6, 0.8], inf)); // Beat amplitude
	~angels.setBeatFreqRatio(Pseq([0.5, 1, 2], inf)); // Beat frequency ratio

	~angels.setBeatAmp(-1);

	~angels.setMapper({|amp, pan, h, speed, pivotx, pivoty, orientation|
		// ~angels.setVibAmount( orientation.linlin(-1.0, 1.0, 0.1, 10.0) );
		~angels.setBeatAmp( orientation );
		// ~angels.setAtk( orientation.linlin( -1.0, 1.0, 0.2, 0.02 ) );
		// ~angels.setDepthStart( pivotx.linlin( 0.0, 1.0, 6.0, 2.0 ) );
		// ~angels.setDepthEnd( pivoty.linlin( 0.0, 1.0, 1.2, 5.0 ) );
		if (speed.notNil, {
			// ~angels.setVibRate( speed.linlin(0.0, 1.0, 10.0, 50.0) );
		},{});
	});

	// ~angels.setVibDepth( 0.2 );
	// ~angels.setVibRate( 10 );
	// ~angels.setBeatAmp( 0.2 );

	~angels.setOctaveRange( 4, 7 );

	~angels.listen;
	// ~angels.play;
	~angels.stop;













	// Voice

	~voice1 = Buffer.read(s, ~path.value( "voice/07_c2_rev_1.aiff" ));
	~voice2 = Buffer.read(s, ~path.value( "voice/07_c2_rev_2.aiff" ));
	~voice3 = Buffer.read(s, ~path.value( "voice/07_c2_rev_3.aiff" ));

	~voice = DarknessToolSample.new("voice", ~in, ~out );
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
	.addTool( ~voice )
	.addTool( ~pulse );

	~control.addSample(\akord, ~akord);

	~control.addEvent(\acordEvent, DarknessEvent.new({
		"started".postln;
		Pdefn(\master, 0.5);
		~control.playSample( \akord, 0.3 );
	},{
		Pdefn(\master, 1);
	}));

	~control.addEvent(\vinetou, DarknessEvent.new({

		~bell.setMelody( Pseq([0,2,4,6,8], inf) );
		~kytar.setMelody( Pseq([8, 6, 4, 2, 0], inf) );
		~voice.setMelody( Pseq([1,3,7,2,8], inf) );
		~piano.setMelody( Pseq([7,3,0,1], inf) );
		~control.setTempoToggling(1);

	},{
		~control.setTempoNormal();
	}));

	~mantraOne = DarknessMelody.new();
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


	~mantraTwo = DarknessMelody.new();
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

	~mantraThree = DarknessMelody.new();
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

	~mantraFour = DarknessMelody.new();
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

	~mantraFive = DarknessMelody.new();
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

	~mantraSix = DarknessMelody.new();
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

	~mantraSeven = DarknessMelody.new();
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

		if(start == true, {
			["Playing buffered content", code ].postln;

			code.switch(
				0, { ~control.playEvent(\acordEvent); },
				1, { ~control.playEvent(\mantraOne); },
				2, { ~control.playEvent(\mantraTwo); },
		  		3, { ~control.playEvent(\mantraThree); },
		  		4, { ~control.playEvent(\mantraFour); },
				5, { ~control.playEvent(\mantraFive); },
				6, { ~control.playEvent(\mantraSix); },
				7, { ~control.playEvent(\mantraSeven); }
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

		["Phase changed", code].postln;

		case {code == 0} {
			~control.applyRandomMelodies;
			~control.setShiftRange(4); // nastaví shift 0..4
		}
		{code == 1} {
			~control.setShiftRange(2); // nastaví shift 0..2
		}
		{code == 2} {
			~control.setShiftRange(1); // nastaví shift 0..1
		}
		{code == 3} {
			~control.setShiftRange(0); // nastaví shift 0
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


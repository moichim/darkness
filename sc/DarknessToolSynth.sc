DarknessToolSynth {

	var <>name;
    var <>synth;

	var <>listeningPort;
	var <>sendingPort;


	var listener;

	var <>msg;
	var <>pattern;


	var <>buf;
	var <>dur;
	var <>amp;
	var <>pan;
	var <>melody;
	var <>shift;
	var <>octave;
	var <>scale;

	var <>listener;
	var <>ampFn;
	var <>panFn;


    var <>atk;
    var <>sus;
    var <>rel;
    var <>depthStart;
    var <>depthEnd;
    var <>vibRate;
    var <>vibDepth;
    var <>beatFreqRatio;
    var <>beatAmp;
    var <>beatRel;

    var <>vibAmount;
    var <>relMax;

	var <>mapper; // anonymní funkce pro mapping orientace



	classvar <processing;

	var <>octaveMin = 2;
	var <>octaveMax = 6;

	var <>durPrevious;

	var <>acceptsDur = true;

	var <>clock;




	*new {| name, synth, listeningPort, sendingPort |

		var instance = super.newCopyArgs(name, synth, listeningPort, sendingPort);

		instance.msg = "/" +/+ name;
		instance.init;

		processing = NetAddr.new( NetAddr.localAddr.hostname, sendingPort );
		instance.clock = TempoClock.new(1);

		^instance;

	}

	// Initialise the object
	init {

		// Inicializace klíčů
		this.buf = this.symbol("Buf");
		this.dur = this.symbol("Dur");
		this.amp = this.symbol("Amp");
		this.pan = this.symbol("Pan");
		this.shift = this.symbol("Shift" );
		this.melody = this.symbol("Melody" );
		this.octave = this.symbol("Octave");
		this.scale = this.symbol("Scale");
		this.pattern = this.symbol("Pattern");
		this.listener = this.symbol("Listener");

        // Specifické pro syntetizovaný synth
        this.atk = this.symbol("Atk");
        this.sus = this.symbol("Sus");
        this.rel = this.symbol("Rel");
        this.depthStart = this.symbol("DepthStart");
        this.depthEnd = this.symbol( "DepthEnd" );
        this.vibRate = this.symbol( "VibRate" );
        this.vibDepth = this.symbol( "VibDepth" );
        this.beatFreqRatio = this.symbol("BeatFreqRatio");
        this.beatAmp = this.symbol( "BeatAmp" );
        this.beatRel = this.symbol( "BeatRel" );

        this.vibAmount = this.symbol( "VibAmount" );
        this.relMax = this.symbol( "RelMax" );


		// Inicializace výchozích hodnot
		Pdefn( this.buf, 0 );
		Pdefn( this.dur, 1 );
		Pdefn( this.amp, 1 );
		Pdefn( this.pan, -1 );
		Pdefn( this.shift, 0 );
		Pdefn( this.melody, 0 );
		Pdefn( this.octave, 4 );
		Pdefn( this.scale, Scale.minorPentatonic );

        Pdefn( this.vibAmount, 1 );
         Pdefn(this.relMax, 0.5);

        // Specifické pro syntetizovaný tool
        Pdefn( this.depthStart, Pseq([6,4,2], inf) );
        Pdefn( this.depthEnd, Pseq( [1.2,2,1.8,5,0.75], inf ) );
        Pdefn( this.atk, Pwhite(0.005, 0.02, inf) );
        Pdefn( this.sus, Pwhite(0.02, 0.25, inf) );
        Pdefn( this.rel, Pwhite( 0.1, Pdefn(this.relMax), inf ));
        Pdefn( this.vibRate, Pseq( [4.0, 50.0, 20.0, 15.0], inf ) );
        Pdefn( this.vibDepth, Pseq([0.01, 0.05, 0.15], inf) );
        Pdefn( this.beatAmp, Pseq([1.0, 0.3, 0.6, 0.9], inf) );
        Pdefn( this.beatFreqRatio, Pseq([0.25, 0.5, 1, 2], inf) );
        Pdefn( this.beatRel, Pwhite(0.03, 0.5, inf) );

        

		// Inicializace vzorku
		Pbindef.new(this.pattern,
			\instrument, this.synth,
			\dur, Pdefn( this.dur),
			\buf,  Pdefn( this.buf ),
			\amp, Pdefn(\master) * Pdefn(this.amp),
			\degree, Pdefn(this.melody) + Pdefn(this.shift),
			\scale, Pdefn( this.scale ),
			\octave, Pdefn(this.octave ) ,
			\pan, Pdefn( this.pan ),

            // Specifické pro syntetizovaný tool
            \depthStart, Pdefn( this.depthStart ),
            \depthEnd, Pdefn( this.depthEnd ),
            \atk, Pdefn( this.atk ),
            \sus, Pdefn( this.sus ),
            \rel, Pdefn( this.rel ),
            \vibRate, Pdefn( this.vibRate ),
            \vibDepth, Pdefn( this.vibDepth ) * Pdefn( this.vibAmount ),
            \beatAmp, Pdefn( this.beatAmp ),
            \beatFreqRatio, Pdefn( this.beatFreqRatio ),
            \beatRel, Pdefn( this.beatRel ),



            // Send beat zpět do Processingu
			\onNote, Pfunc({
				processing.sendMsg(this.msg);
			})
		);

		("Initialised Pbindef" ++ this.name).postln;

		// Inicializace listeneru
		OSCdef.newMatching(this.listener, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speedAvg = msg[4], pivotx = msg[5], pivoty=msg[6], speed=msg[7], orientation=msg[8];

			this.setAmp( amp );

			this.setPan( pan );

			this.mapOctave( pivoty );

			if(this.mapper.notNil, {
				this.mapper.value(amp, pan, h, speed, pivotx, pivoty, orientation);
			}, {});

			this.setTempo( speedAvg.asStringPrec(2).asFloat.linexp(0.0, 1.0, 1, 1.5).min(1.5).max(1) );

		},
		this.msg,
		recvPort: this.listeningPort
		);


	}

	symbol {| value |
		var result = ( this.name.asString ++ value.asString );
		^result.asSymbol();
	}


	play {

		Pbindef(this.pattern).play(this.clock);
		["Spouštím", this.name].postln;

	}

	stop {

		Pbindef(this.pattern).stop;
		["Zastavuji", this.name].postln;

	}

	setTempo { |tempo|

	this.clock.tempo = tempo;
		if (this.acceptsDur == true, {
			// this.clock.tempo = tempo;
		},{
			// this.clock.tempo = 1;
		});
	}

	setBuf {
		|value|
		Pdefn( this.buf, value );
	}

	setDur {
		|value|
		Pdefn( this.dur, value );
		this.durPrevious = value;
	}

	resetDur {
		if(this.durPrevious.notNil, {
			this.setDur( this.durPrevious );
			this.durPrevious = nil;
		},{});
	}

	setAmp {| value |

		var sanitized;

		if (value.isNil) {
			// Pokud je nil, zastavit a nastavit amp na 0
			Pbindef(this.pattern).stop;
			Pdefn(this.amp, 0);
			("[" ++ this.name ++ "] amp is nil, stopping").postln;
			^this;
		};

		sanitized = value.max(0.0).min(0.8);

		Pdefn( this.amp, sanitized );

		if (sanitized < 0.02) {
			if (this.isPlaying) {
				Pbindef(this.pattern).stop;
				("[" ++ this.name ++ "] stopped due to low amp").postln;
			};
		} {
			if (this.isPlaying.not) {
				Pbindef(this.pattern).play(this.clock);
				("[" ++ this.name ++ "] started due to sufficient amp").postln;
			};
		};

	}

	setMelody {
		|value|
		Pdefn( this.melody, value );
	}

	setShift {
		|value|

		if (value.isNil) {
			("[" ++ this.name ++ "] shoft is nil").postln;
			^this;
		};

		Pdefn( this.shift, value );
	}

	setOctave {
		|value|
		var sanitized;
		if (value.isNil) {
			("[" ++ this.name ++ "] shoft is nil").postln;
			^this;
		};

		sanitized = value.min(this.octaveMax).max( this.octaveMin ).floor.asInteger;

		Pdefn( this.octave, sanitized );
	}

	mapOctave {
		|value|
		var sanitized;
		if (value.isNil) {
			("[" ++ this.name ++ "] shoft is nil").postln;
			^this;
		};

		sanitized = value.linlin( 0.0, 1.0, this.octaveMax, this.octaveMin ).floor.asInteger;

		Pdefn( this.octave, sanitized );
	}

	setOctaveRange {|min,max|
		this.octaveMin = min.min(max).min(15).max(0).floor.asInteger;
		this.octaveMax = max.max(min).max(0).floor.asInteger;
	}

	setScale {
		|value|
		Pdefn( this.scale, value );
	}

	setPan {| value |
		var sanitized = value.max(-1.0).min(1.0);
		Pdefn( this.pan, sanitized );
		Pbindef( this.pattern ).set(\pan, sanitized);
	}

	isPlaying {
		var player = Pbindef(this.pattern).player;
		var isPlaying = player.notNil and: { player.isPlaying };
		^isPlaying;
	}

	listen {
		OSCdef(this.listener).enable;
		( "Started listening " ++ this.msg ).postln;
	}

    stopListening {
		OSCdef(this.listener).disable;
		( "Started listening " ++ this.msg ).postln;
	}

    setDepthStart {|value|
        Pdefn( this.depthStart, value );
    }

    setDepthEnd {|value|
        Pdefn( this.depthEnd, value );
    }

    setAtk {|value|
        Pdefn( this.atk, value );
    }

    setSus {|value|
        Pdefn( this.sus, value );
    }

    setRel {|value|
        Pdefn( this.rel, value );
    }

    setVibRate {|value|
        Pdefn( this.vibRate, value );
    }

    setVibDepth {|value|
        Pdefn( this.vibDepth, value );
    }


    setVibAmount {|value|
        Pdefn( this.vibAmount, value );
    }

    setBeatAmp {|value|
        Pdefn( this.beatAmp, value );
    }

    setBeatFreqRatio {|value|
        Pdefn( this.beatFreqRatio, value );
    }

    setBeatRel {|value|
        Pdefn( this.beatRel, value );
    }

    setRelMax {|value|
        Pdefn( this.relMax, value )
    }

	setMapper { |func|
		this.mapper = func;
	}

	mute {
		OSCdef(this.listener).enable;
		this.stop;
		( "Stopped listening " ++ this.msg ).postln;
	}





}
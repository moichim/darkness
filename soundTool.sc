DarknessTool {

	var <>name;

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

	classvar <processing;

	var <>octaveMin = 2;
	var <>octaveMax = 6;




	*new {| name, listeningPort, sendingPort |

		var instance = super.newCopyArgs(name, listeningPort, sendingPort);

		instance.msg = "/" +/+ name;
		instance.init;

		processing = NetAddr.new( NetAddr.localAddr.hostname, sendingPort );

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

		// Inicializace výchozích hodnot
		Pdefn( this.buf, 0 );
		Pdefn( this.dur, 1 );
		Pdefn( this.amp, 1 );
		Pdefn( this.pan, -1 );
		Pdefn( this.shift, 0 );
		Pdefn( this.melody, 0 );
		Pdefn( this.octave, 3 );
		Pdefn( this.scale, Scale.minorPentatonic );

		// Inicializace vzorku
		Pbindef.new(this.pattern,
			\instrument, \sampler,
			\dur, Pdefn( this.dur),
			\buf,  Pdefn( this.buf ),
			\amp, Pdefn(\master) * Pdefn(this.amp),
			\degree, Pdefn(this.melody) + Pdefn(this.shift),
			\scale, Pdefn( this.scale ),
			\octave, Pdefn(this.octave ) ,
			\pan, Pdefn( this.pan ),
			\onNote, Pfunc({
				this.name.postln;
				processing.sendMsg(this.msg);
			})
		);

		("Initialised Pbindef" ++ this.name).postln;

		// Inicializace listeneru
		OSCdef.newMatching(this.listener, { |msg, time, addr, recvPort|
		var amp = msg[1], pan = msg[2], h = msg[3], speed = msg[4], pivotx = msg[5], pivoty=msg[6];

			this.setAmp( amp );

			this.setPan( pan );

			this.setOctave( pivoty );

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

		Pbindef(this.pattern).play;
		"Spouštím".postln;

	}

	stop {

		Pbindef(this.pattern).stop;
		"Zastavuji".postln;

	}

	setBuf {
		|value|
		Pdefn( this.buf, value );
	}

	setDur {
		|value|
		Pdefn( this.dur, value );
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

		sanitized = value.max(0.0).min(1.0);

		Pdefn( this.amp, sanitized );

		if (sanitized < 0.02) {
			if (this.isPlaying) {
				Pbindef(this.pattern).stop;
				("[" ++ this.name ++ "] stopped due to low amp").postln;
			};
		} {
			if (this.isPlaying.not) {
				Pbindef(this.pattern).play;
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
		this.octaveMin = min.min(max).min(10).max(0).floor.asInteger;
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

	mute {
		OSCdef(this.listener).enable;
		this.stop;
		( "Stopped listening " ++ this.msg ).postln;
	}





}
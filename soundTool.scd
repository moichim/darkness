DarknessTool {

	var <>name;

	var <listeningPort;
	var <sendingPort;


	var listener;

	var <>msg;
	var <>pattern;
	var playing = false;


	var <>buf;
	var <>dur;
	var <>amp;
	var <>pan;
	var <>melody;
	var <>shift;
	var <>octave;
	var <>scale;

	var <>volume;
	var <>degree;




	*new {| name, listeningPort, sendingPort |

		var instance = super.newCopyArgs(name, listeningPort, sendingPort);

		instance.msg = "/" +/+ name;

		^instance;

	}

	// Initialise the object
	init { |buf|

		this.buf = Pdefn.new( this.symbol("Buf"), buf );

		this.dur = Pdefn.new(this.symbol("Dur"), 1);

		this.amp = Pdefn.new( this.symbol("Amp"), 0 );
		this.pan = Pdefn.new( this.symbol("Pan"), 0 );
		this.shift = Pdefn.new( this.symbol("Shift" ), 0);
		this.melody = Pdefn.new( this.symbol("Melody" ), Pseq([0, 1, 2, 3, 4, 0, 0], inf) );
		this.octave = Pdefn.new( this.symbol("Octave"), 0 );
		this.scale = Pdefn( this.symbol("Scale"), Scale.minorPentatonic);

		this.volume = Pdefn.new(this.symbol("Volume"), Pfuncn({
			Pdefn( \master ) * Pdefn( this.symbol("Amp") );
		}, inf));

		this.degree = Pdefn.new(this.symbol("Degree"),
		Pfuncn({
				Pdefn( this.symbol("Melody") ) + Pdefn( this.symbol("Shift"))
		}, inf)
	);

		this.pattern = Pbindef.new( this.symbol("Pattern") );


	}

	symbol {| value |
		var result = ( this.name.asString ++ value.asString );
		^result.asSymbol();
	}


	play {

		Pbindef(this.symbol("Pattern")).set(
			\instrument, \sample,
			\buf,  this.buf,
			\amp, this.volume,
			\dur, this.dur,
			\degree, this.degree,
			\scale, this.scale,
			\octave, this.octave,
			\pan, this.pan,
			\onNote, Pfunc({|event|
				this.name.postln;
				this.event.postln;
			})
		);



		Pbindef(this.symbol("Pattern")).play();

	}

	stop {

		Pbindef(this.symbol("Pattern")).stop;

	}



	setAmp {| value |
		var sanitized = value.max(0.0).min(1.0);
		Pdefn( this.symbol('Amp'), sanitized );
		sanitized.postln;
		this.pattern.set( \amp, sanitized );
	}

	setPan {| value |
		var sanitized = value.max(-1.0).min(1.0);
		this.pan.set( sanitized );
		// Pdefn( this.symbol('Pan'), sanitized );
		sanitized.postln;
		// this.pattern.set( \pan, sanitized );
	}





}
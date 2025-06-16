DarknessControl {

	var <>tools;
	var <>samples;
	var <>events;
	var <>melodies;

	var <>event;

	*new {
		var instance = super.new();

		instance.tools = Array.new(4);
		instance.samples = Dictionary.new;
		instance.events = Dictionary.new;
		instance.melodies = Dictionary.new;

		^instance;
	}

	addTool {| value |
		this.tools.add(value);
	}

	getTools {
		^this.tools;
	}

	playAll {
		this.tools.do({| item |
			item.play;
		});
	}

	stopAll {
		this.tools.do({| item |
			item.stop;
		});
	}

	getPlaying {
		var playing = Array.new(4);
		this.tools.do({| item |
			if(item.isPlaying, {
				playing.add(item);
			},{})
		});
		^playing;
	}

	setTempoToggling{
		|tempo|
		var playing = this.getPlaying();
		var size = playing.size;
		var tempoValid = tempo.notNil and: { tempo.isNumber and: { tempo > 0.2 } };
		var dur = if( tempoValid, tempo, size );

		if (size>0,{
			playing.do({| item, index |
			var delay = index * ( dur / size );
			item.setDur(Pseq([ Pseq([index],1), Pseq([dur],inf)]), 1);
		});
		},{});
	}

	setTempoNormal {
		this.tools.do({|item|
			item.resetDur();
		});
	}

	addSample {| name, value |
		this.samples.put(name,value);
	}

	playSample {|name, amp|
		this.samples.at(name).postln;
		Synth.new(\sampler, [
			\buf, this.samples.at(name).bufnum,
			\amp, amp.min(0.0).max(1.0)
		]);
	}


	addEvent {|name, value|
		this.events.put(name, value);
	}

	playEvent {|name|
		if(this.event.isNil and: {this.events.includesKey(name)}, {
			this.event = this.events.at(name);
			this.event.start;
			["Playing event:", this.event].postln;
		},{});
	}

	endEvent {
		if(this.event.notNil, {
			this.event.end;
			this.event = nil;
		},{});
	}

	addMelody {|key,value|
		this.melodies.put(key, value);
	}

	playMelody {|key|
		if(this.melodies.includesKey(key), {
			this.melodies.at(key).playEntireMelody;
		});
	}

	applyRandomMelodies {
		var keys = this.melodies.keys;
		if(keys.size > 0, {
			var key = keys.choose;
			this.applyMelodiesOnly(key);
		}, {
			"No melodies available to play.".postln;
		});
	}

	setShiftRange {|number|
		var range = (0..number);
		this.tools.do({|item|
			item.setShift(Pxrand(range, inf));
		});
	}

}
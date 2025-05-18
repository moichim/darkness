DarknessControl {

	var <>tools;

	*new {
		var instance = super.new();

		instance.tools = Array.new(4);

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
			item.postln;
			item.play;
		});
	}

	stopAll {
		this.tools.do({| item |
			item.postln;
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

}
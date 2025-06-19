DarknessToolSynth : DarknessToolBase {

    var <>synth;
    var <>atk, <>sus, <>rel, <>depthStart, <>depthEnd, <>vibRate, <>vibDepth, <>beatFreqRatio, <>beatAmp, <>beatRel;
    var <>vibAmount, <>relMax;

    *new { |name, listeningPort, sendingPort|
		var instance = super.new(name, listeningPort, sendingPort);
		^instance;
	}

	setSynth { |synth|
		this.synth = synth;
		^this;
	}

    init {
        super.init;

        this.atk = this.symbol("Atk");
        this.sus = this.symbol("Sus");
        this.rel = this.symbol("Rel");
        this.depthStart = this.symbol("DepthStart");
        this.depthEnd = this.symbol("DepthEnd");
        this.vibRate = this.symbol("VibRate");
        this.vibDepth = this.symbol("VibDepth");
        this.beatFreqRatio = this.symbol("BeatFreqRatio");
        this.beatAmp = this.symbol("BeatAmp");
        this.beatRel = this.symbol("BeatRel");
        this.vibAmount = this.symbol("VibAmount");
        this.relMax = this.symbol("RelMax");

		Pdefn(this.vibAmount, 1);
        Pdefn(this.relMax, 0.5);
        Pdefn(this.atk, Pwhite(0.005, 0.02, inf));
        Pdefn(this.sus, Pwhite(0.02, 0.25, inf));
        Pdefn(this.rel, Pwhite(0.1, Pdefn(this.relMax), inf));
        Pdefn(this.depthStart, Pseq([6,4,2], inf));
        Pdefn(this.depthEnd, Pseq([1.2,2,1.8,5,0.75], inf));
        Pdefn(this.vibRate, Pseq([4.0, 50.0, 20.0, 15.0], inf));
        Pdefn(this.vibDepth, Pseq([0.01, 0.05, 0.15], inf));
        Pdefn(this.beatAmp, Pseq([1.0, 0.3, 0.6, 0.9], inf));
        Pdefn(this.beatFreqRatio, Pseq([0.25, 0.5, 1, 2], inf));
        Pdefn(this.beatRel, Pwhite(0.03, 0.5, inf));

        this.makePattern;

        OSCdef.newMatching(this.listener, { |msg, time, addr, recvPort|
            var amp = msg[1], pan = msg[2], h = msg[3], speedAvg = msg[4], pivotx = msg[5], pivoty = msg[6], speed = msg[7], orientation = msg[8];

            this.setAmp(amp);
            this.setPan(pan);
            this.mapOctave(pivoty);

            if(this.mapper.notNil, {
                this.mapper.value(amp, pan, h, speed, pivotx, pivoty, orientation);
            });
			// Tempo se aktualizuje pouze pokud je to nastaveno
            if(this.oscTempoEnabled == true) {
    			this.setTempo(speedAvg.asStringPrec(2).asFloat.linexp(0.0, 1.0, 1, 1.5).min(1.5).max(1));
			};
        }, this.msg, recvPort: this.listeningPort);
    }

    makePattern {
        Pbindef.new(this.pattern,
            \instrument, this.synth,
            \dur, Pdefn(this.dur),
            \amp, Pdefn(\master) * Pdefn(this.amp),
            \degree, Pdefn(this.melody) + Pdefn(this.shift),
            \scale, Pdefn(this.scale),
            \octave, Pdefn(this.octave),
            \pan, Pdefn(this.pan),
            \depthStart, Pdefn(this.depthStart),
            \depthEnd, Pdefn(this.depthEnd),
            \atk, Pdefn(this.atk),
            \sus, Pdefn(this.sus),
            \rel, Pdefn(this.rel),
            \vibRate, Pdefn(this.vibRate),
            \vibDepth, Pdefn(this.vibDepth) * Pdefn(this.vibAmount),
            \beatAmp, Pdefn(this.beatAmp),
            \beatFreqRatio, Pdefn(this.beatFreqRatio),
            \beatRel, Pdefn(this.beatRel),
            \onNote, Pfunc({ processing.sendMsg(this.msg); this.msg.postln; })
        );
        ("Initialised Pbindef " ++ this.name).postln;
		this.pattern.postln;
		Pbindef(this.pattern).postln;
    }

    setDepthStart {|value| Pdefn(this.depthStart, value); }
    setDepthEnd {|value| Pdefn(this.depthEnd, value); }
    setAtk {|value| Pdefn(this.atk, value); }
    setSus {|value| Pdefn(this.sus, value); }
    setRel {|value| Pdefn(this.rel, value); }
    setVibRate {|value| Pdefn(this.vibRate, value); }
    setVibDepth {|value| Pdefn(this.vibDepth, value); }
    setVibAmount {|value| Pdefn(this.vibAmount, value); }
    setBeatAmp {|value| Pdefn(this.beatAmp, value); }
    setBeatFreqRatio {|value| Pdefn(this.beatFreqRatio, value); }
    setBeatRel {|value| Pdefn(this.beatRel, value); }
    setRelMax {|value| Pdefn(this.relMax, value); }
}
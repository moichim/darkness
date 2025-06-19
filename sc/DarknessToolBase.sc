DarknessToolBase {

    var <>name, <>listeningPort, <>sendingPort, <>listener, <>msg, <>pattern, <>clock;
    var <>buf, <>dur, <>amp, <>pan, <>melody, <>shift, <>octave, <>scale;
    var <>octaveMin = 2, <>octaveMax = 6, <>durPrevious, <>acceptsDur = true;
    var <>mapper;

    // ...existing variables...
    var lastTempo, lastDur;
    var <>oscTempoEnabled = true; // přepínač pro OSC tempo

    classvar <processing;

    *new {| name, listeningPort, sendingPort |
        var instance = super.newCopyArgs(name, listeningPort, sendingPort);
        instance.msg = "/" +/+ name;
        // instance.init;
        processing = NetAddr.new(NetAddr.localAddr.hostname, sendingPort);
        instance.clock = TempoClock.new(1);
        ^instance;
    }

    init {
        this.buf = this.symbol("Buf");
        this.dur = this.symbol("Dur");
        this.amp = this.symbol("Amp");
        this.pan = this.symbol("Pan");
        this.shift = this.symbol("Shift");
        this.melody = this.symbol("Melody");
        this.octave = this.symbol("Octave");
        this.scale = this.symbol("Scale");
        this.pattern = this.symbol("Pattern");
        this.listener = this.symbol("Listener");

        Pdefn(this.buf, 0);
        Pdefn(this.dur, 1);
        Pdefn(this.amp, 1);
        Pdefn(this.pan, 0);
        Pdefn(this.shift, 0);
        Pdefn(this.melody, 0);
        Pdefn(this.octave, 4);
        Pdefn(this.scale, Scale.minorPentatonic);
    }


    playMelody { |dur, melody, octave|
        // Ulož poslední hodnoty
        lastTempo = this.clock.tempo;
        lastDur = Pdefn(this.dur).source;

        // Nastav tempo na 1 a vypni OSC tempo
        this.clock.tempo = 1;
        oscTempoEnabled = false;

        // Nastav melodii, oktávu a dočasné dur pokud jsou předány
        if (melody.notNil, { this.setMelody(melody); }, {});
        if (octave.notNil, { this.setOctave(octave); },{});
        if (dur.notNil, { this.setDur(dur); },{});
    }

    stopMelody {
        // Obnov poslední tempo a dur
        if (lastTempo.notNil, { this.clock.tempo = lastTempo; },{});
        if (lastDur.notNil, { this.setDur(lastDur); },{});
        oscTempoEnabled = true; // Zapni OSC tempo
    }





    symbol {| value | ^(this.name.asString ++ value.asString).asSymbol }

    play { Pbindef(this.pattern).play(this.clock); (this.name + " starts").postln; }
    stop { Pbindef(this.pattern).stop; (this.name + " stops").postln; }

    setTempo {|tempo| this.clock.tempo = tempo; }
    setBuf {|value| Pdefn(this.buf, value); }
    setDur {|value| Pdefn(this.dur, value); this.durPrevious = value; }
    resetDur {
        if(this.durPrevious.notNil, {
            this.setDur(this.durPrevious);
            this.durPrevious = nil;
        });
    }
    setAmp {|value|
        var sanitized;
        if (value.isNil) {
            Pbindef(this.pattern).stop;
            Pdefn(this.amp, 0);
            ^this;
        };
        sanitized = value.max(0.0).min(1.0);
        Pdefn(this.amp, sanitized);
        if (sanitized < 0.02) {
            if (this.isPlaying) { Pbindef(this.pattern).stop; }
        } {
            if (this.isPlaying.not) { Pbindef(this.pattern).play(this.clock); }
        };
    }
    setMelody {|value| Pdefn(this.melody, value); }
    setShift {|value| if (value.notNil) { Pdefn(this.shift, value); } }
    setOctave {|value|
        if (value.notNil) {
            var sanitized = value.min(this.octaveMax).max(this.octaveMin).floor.asInteger;
            Pdefn(this.octave, sanitized);
        }
    }
    mapOctave {|value|
        if (value.notNil) {
            var sanitized = value.linlin(0.0, 1.0, this.octaveMax, this.octaveMin).floor.asInteger;
            Pdefn(this.octave, sanitized);
        }
    }
    setOctaveRange {|min, max|
        this.octaveMin = min.min(max).min(15).max(0).floor.asInteger;
        this.octaveMax = max.max(min).max(0).floor.asInteger;
    }
    setScale {|value| Pdefn(this.scale, value); }
    setPan {|value|
        var sanitized = value.max(-1.0).min(1.0);
        Pdefn(this.pan, sanitized);
        Pbindef(this.pattern).set(\pan, sanitized);
    }
    isPlaying {
        var player = Pbindef(this.pattern).player;
        ^player.notNil and: { player.isPlaying };
    }
    listen { OSCdef(this.listener).enable; }
    stopListening { OSCdef(this.listener).disable; }
    setMapper {|func| this.mapper = func; }
    mute { OSCdef(this.listener).enable; this.stop; }
}
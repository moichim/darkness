DarknessMelody {

    var <>durs;
    var <>melodies;
    var <>octaves;

    *new {|key|
        var instance = super.new();
        instance.durs = Dictionary.new;
        instance.melodies = Dictionary.new;
        instance.octaves = Dictionary.new;
        ^instance;
    }

    addLine {|tool, dur, melody, octave|
        if( melody.notNil, { 
            this.melodies.put( tool, melody ) 
        }, {});
        if( octave.notNil, { 
            this.octaves.put( tool, octave ) 
        }, {});
        if( dur.notNil, { 
            this.durs.put( tool, dur ) 
        }, {});
    }

    playEntireMelody {

        ["Applying melody", this].postln;

        this.durs.keys.do { | key | key.setDur(this.durs.at(key)) };
        this.melodies.keys.do { | key | key.setMelody(this.melodies.at(key)) };
        this.octaves.keys.do { | key | key.setOctave(this.octaves.at(key)) };
    }

    applyMelodiesOnly {

        this.melodies.keys.do { | key |
            var melody = this.melodies.at(key);
            if( melody.notNil, {
                key.setMelody(melody);
            }, {});
        };
    }

}
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


        // Získej všechny nástroje, které mají alespoň jednu hodnotu
        var allTools = (this.durs.keys ++ this.melodies.keys ++ this.octaves.keys).asSet;

        allTools.do { |tool|
            var dur = this.durs.at(tool);
            var melody = this.melodies.at(tool);
            var octave = this.octaves.at(tool);
            tool.playMelody(dur, melody, octave);
        };

        ["Applying melody", this].postln;

        /*

        this.durs.keys.do { | key | key.setDur(this.durs.at(key)) };
        this.melodies.keys.do { | key | key.setMelody(this.melodies.at(key)) };
        this.octaves.keys.do { | key | key.setOctave(this.octaves.at(key)) };

        */
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
SoundMelody {

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
        melody.postln;
        melody.notNil.postln;
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

    apply {

        this.durs.keys.do { | key | [key].postln };
        this.durs.keys.do { | key | key.setDur(this.durs.at(key)) };
        this.melodies.keys.do { | key | key.setMelody(this.melodies.at(key)) };
        this.octaves.keys.do { | key | key.setOctave(this.octaves.at(key)) };
    }

}
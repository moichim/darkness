enum SOUND {
    MUTED,
    ONE,
    MULTIPLE,
    MELODY
}

class Composition {

    protected SoundPhaseMuted muted = new SoundPhaseMuted();
    protected SoundPhaseOne one = new SoundPhaseOne();
    protected SoundPhaseMultiple multiple = new SoundPhaseMultiple();
    protected SoundPhaseMelody melody = new SoundPhaseMelody();
    
    protected SoundPhase current = this.muted;

    int ticks = 0;

    int melodyTicksLimit = 300;

    int phaseMinLife = 30 * 2;

    float oneAmp = 0;
    float multipleAmp = 0;

    float changeStep = 0.02;

    Composition() {
        this.current.activate();
    }

    public void update() {

        this.ticks = this.ticks + 1;

        this.evaluatePhase();

        this.current.execute( this.ticks );

        if ( this.ticks >= 10000 ) {
            this.ticks = 0;
        }

        // Send messages of all trackers
        // if ( frameCount % 10 == 0 ) {
        if (controller.trackers.recording == true) {
            controller.trackers.sendInstrumentMessages( 1 );
        }
        // }

        /*

        fill( 0 );
        rectMode(CORNER);
        rect(0, height - 200, 400, 200);

        fill( 255 );
        noStroke();

        ellipseMode( CENTER );

        float instDiameter = map( this.oneAmp, 0, 1, 0, 200 );
        ellipse(
            100,
            height - 200,
            instDiameter,
            instDiameter
        );

        float multipleDiameter = map( this.multipleAmp, 0, 1, 0, 200 );
        ellipse(
            300,
            height - 200,
            multipleDiameter,
            multipleDiameter
        );

        */

    }

    void evaluatePhase() {

        // If there are no particles, set muted
        if ( controller.particles.points.size() <= 0 ) {
            if ( this.current.key() != SOUND.MUTED ) {
                this.activatePhase( this.muted );
            }
        }

        // If there is only one color and maximum of 3 trackers, set one
        else if ( controller.trackers.numActiveColors == 1 && this.ticks > this.phaseMinLife ) {
            if ( this.current.key() != SOUND.ONE ) {
                this.activatePhase( this.one );
            }
        }

        // If there are at least two colors, set multiple
        else if ( controller.trackers.numActiveColors > 1 && this.ticks > this.phaseMinLife && this.ticks <= this.melodyTicksLimit && this.current.key() != SOUND.MELODY ) {
            if ( this.current.key() != SOUND.MULTIPLE ) {
                this.activatePhase( this.multiple );
            }
        }

        // If there are at least two colors and the phase life is larger than X, set melody
        else if ( controller.trackers.numActiveColors > 1 && this.ticks > this.phaseMinLife && this.ticks > this.melodyTicksLimit ) {
            if ( this.current.key() != SOUND.MELODY ) {
                this.activatePhase( this.melody );
            }
        }

    }

    public void activatePhase( SoundPhase phase ) {
        this.current.end();
        this.current = phase;
        this.ticks = 0;
        this.current.activate();
    }

    public void raiseOne() {

        if ( this.oneAmp < 1 ) {
            this.oneAmp += this.changeStep;
        } else {
            this.oneAmp = 1;
        }

    }

    public void raiseMultiple() {

        if ( this.multipleAmp < 1 ) {
            this.multipleAmp += this.changeStep;
        } else {
            this.multipleAmp = 1;
        }

    }

    public void muteOne() {
        if ( this.oneAmp > 0 ) {
            this.oneAmp -= this.changeStep;
        } else {
            this.oneAmp = 0;
        }
    }

    public void muteMultiple() {
        if ( this.multipleAmp > 0 ) {
            this.multipleAmp -= this.changeStep;
        } else {
            this.multipleAmp = 0;
        }
    }

    public void goMultipleTo( float target ) {

        float distance = this.changeStep * 1.5;

        target = constrain( target, 0, 1 );

        if ( target == this.multipleAmp ) {
            // Do nothing
        }
        else if ( abs( this.multipleAmp - target ) <= distance ) {
            this.multipleAmp = target;
        }
        else if ( this.multipleAmp < target ) {
            this.multipleAmp += this.changeStep;
        } 
        else if ( this.multipleAmp > target ) {
            this.multipleAmp -= this.changeStep;
        }

    }

    public void goOneTo( float target ) {

        float distance = this.changeStep * 1.5;

        target = constrain( target, 0, 1 );
        if ( target == this.oneAmp ) {
            // Do nothing
        }
        else if ( abs( this.oneAmp - target ) <= distance ) {
            this.oneAmp = target;
        }
        else if ( this.oneAmp < target ) {
            this.oneAmp += this.changeStep;
        } 
        else if ( this.oneAmp > target ) {
            this.oneAmp -= this.changeStep;
        }

    }



}
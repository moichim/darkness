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

    }

    void evaluatePhase() {


        // If there are no particles, set muted

        // If there is only one color and maximum of 3 trackers, set one

        // If there are at least two colors, set multiple

        // If there are at least two colors and the phase life is larger than X, set melody


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



}
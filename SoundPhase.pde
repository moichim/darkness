abstract class SoundPhase {

    abstract SOUND key();

    abstract void activate();

    abstract void execute( int ticks );

    abstract void end();

}

class SoundPhaseMuted extends SoundPhase {

    SOUND key() {return SOUND.MUTED; }

    void activate() {
        println( "activating", this.key() );
    }

    void execute( int ticks ) {

    }

    void end() {

        println( "deactivating", this.key() );

    }

}

class SoundPhaseOne extends SoundPhase {

    SOUND key() { return SOUND.ONE; }

    void activate() {

        println( "activating", this.key() );

    }

    void execute( int ticks ) {

    }

    void end() {

        println( "deactivating", this.key() );

    }

}

class SoundPhaseMultiple extends SoundPhase {

    SOUND key() { return SOUND.MULTIPLE; }

    void activate() {

        println( "activating", this.key() );

    }

    void execute( int ticks ) {

    }

    void end() {

        println( "deactivating", this.key() );

    }

}

class SoundPhaseMelody extends SoundPhase {

    SOUND key() { return SOUND.MELODY; }

    protected ArrayList<Boolean> colors = new ArrayList<Boolean>();
    protected ArrayList<Integer> intervals = new ArrayList<Integer>();
    protected int pointer = 0;

    protected int counter = 0;

    void activate() {

        println( "activating", this.key() );

        this.colors.clear();
        this.intervals.clear();

        controller.setBga(10);

        controller.setColorDeviationThreshold(15);

        this.counter = 0;
        this.pointer = 0;

        int max = (int) round( random( 3, 5 ) );

        for ( int i = 1; i <= max; i++ ) {

            if ( i == max ) {
                this.colors.add( true );
            } else {
                this.colors.add( false );
            }

            this.intervals.add( 50 );

        }


    }

    void execute( int ticks ) {

        this.counter++;

        if ( this.pointer >= this.intervals.size() ) {
            this.pointer = 0;
        }

        int interval = this.intervals.get( this.pointer );
        boolean implicite = this.colors.get( this.pointer );

        if ( this.counter == (int) round (interval/2 ) ) {
            this.propagateColor(true);
        }

        if ( this.counter >= interval ) {
            this.counter = 0;
            this.propagateColor( implicite );
            this.pointer++;
        }

    }

    void end() {

        println( "deactivating", this.key() );

        controller.setBga(15);

        controller.setColorDeviationThreshold(40);

        for ( Tracker tracker : controller.trackers ) {
            tracker.emissionColor = tracker.trackColor;
        }

    }

    void propagateColor(
        boolean implicite
    ) {

        color col = color( random(128), random(128), random(128) );
        float deviation = random(0,10);

        for ( Particle particle : controller.particles.points ) {

            if ( implicite == true ) {
                particle.setColorFromTracker();
            } else {
                particle.setColor( col, deviation );
            }

        }

        for ( Tracker tracker : controller.trackers ) {
            if ( implicite == true ) {
                tracker.emissionColor = tracker.trackColor;
                println( "propagating the implicite color" );
            } else {
                tracker.emissionColor = col;
                println( "propagating a random color", col );
            }
        }

        
    }

}
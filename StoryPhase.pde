enum PHASE {
    MUTED,
    ONE,
    MULTIPLE,
    EVENT
}

class StoryPhase {

    Story story;

    protected StoryPhaseMuted muted;
    protected StoryPhaseOne one;
    protected StoryPhaseMultiple multiple;
    protected StoryPhaseEvent event;

    protected StoryPhaseAbstract current = this.muted;

    protected int ticks = 0;

    protected int phaseMinLife = 30 * 2;
    protected int eventPhaseLimit = 300; // Minimal amount of ticks until the next event triggers

    StoryPhase( Story story ) {

        this.story = story;

        this.muted = new StoryPhaseMuted( this.story );
        this.one = new StoryPhaseOne( this.story );
        this.multiple = new StoryPhaseMultiple( this.story );
        this.event = new StoryPhaseEvent( this.story );

        this.current = this.muted;

    }

    public StoryPhaseAbstract getCurrentPhase() {
        return this.current;
    }

    void update() {

        this.determinePhase();

        this.sendInstrumentMessages();

        /*

        push();

        fill( 255 );

        text( this.current.code() + " ticks:" + this.ticks, width - 200, height- 20 );

        pop();

        */

    }

    protected void determinePhase() {

        int numPlayingTools = this.story.getNumPlayingTools();

        // If there are jo particles, set muted
        if ( numPlayingTools <= 0 ) {
            this.holdPhaseActive( this.muted );
        }
        // If there is only one playing tool, set one
        else if ( numPlayingTools == 1 ) {
            this.holdPhaseActive( this.one );
        }
        // If there are more than one tools playing, proceed...
        else if ( numPlayingTools > 1 ) {

            if ( this.current != this.event ) {
                if ( this.ticks > this.eventPhaseLimit ) {
                    this.holdPhaseActive( this.event );
                } else {
                    this.holdPhaseActive( this.multiple );
                }
            } else {
                this.holdPhaseActive( this.event );
            }

            

        }


    }

    public void holdPhaseActive( StoryPhaseAbstract phase ) {

        // If the phase is already active OR if it is too early for a change, do tick
        if ( 
            this.current.code() == phase.code() 
            || this.ticks < this.phaseMinLife
        ) {
            this.ticks += 1;
            this.current.execute( this.ticks );
        }
        // If the phase is different, activate the new phase
        else {

            // Activate the new phase
            this.current.end();
            phase.activate();
            this.current = phase;
            this.ticks = 0;
            
            // Send the phase code to the controller
            OscMessage msg = controller.msg("/phase");
            msg.add( this.current.code() );
            controller.send(msg);

        }


    }

    public void sendInstrumentMessages() {

        if (this.story.controller.trackers.recording == true) {
            this.story.controller.trackers.sendInstrumentMessages( 10 );
        }

    }


}
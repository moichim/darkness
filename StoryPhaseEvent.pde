import java.util.Collections;

class StoryPhaseEvent extends StoryPhaseAbstract {

    ArrayList<EventAbstract> events = new ArrayList<EventAbstract>();

    protected EventAbstract current;

    protected int duration;

    protected int localTick = 0;

    StoryPhaseEvent( Story story ) {

        super(story);

        // this.events.add( new EventRandom( story ) );
        this.events.add( new EventAcord( this.story ) );
        // this.events.add( new EventVinetou( this.story ) );
        
        // this.events.add( new EventMantraOne( this.story ) );
        // this.events.add( new EventMantraTwo( this.story ) );
        /*
        this.events.add( new EventMantraThree( this.story ) );
        this.events.add( new EventMantraFour( this.story ) );
        this.events.add( new EventMantraFive( this.story ) );
        this.events.add( new EventMantraSix( this.story ) );
        this.events.add( new EventMantraSeven( this.story ) );
        // this.events.add( new EventMiddle( story ) );
        */

    }

    PHASE key() {return PHASE.EVENT; }

    int code() { return 3; }

    int duration() { return this.duration; }

    void onActivate() {
        
        this.getStory().forEveryTool( (tool) -> {
            tool.eventOn();
        });
    
        // Reassign the event
        this.current = this.selectEvent();
        
        // Activate the event
        this.current.onActivate();

        // Mirror the duration
        this.duration = this.current.getDuration();

        this.localTick = 0;

    }


    protected EventAbstract selectEvent() {

        if ( this.events.size() > 0 ) {

            // Get the first event
            EventAbstract first = this.events.get(0);

            // Remove the first event from the buffer
            this.events.remove(0);

            EventAbstract last = null;

            // eventually get the last event
            if ( this.events.size() > 1 ) {
                int index = this.events.size() - 1;
                last = this.events.get( index );
                this.events.remove( index );
            }

            // Shuffle events randomly
            java.util.Collections.shuffle( this.events );

            // Eventually, append the last event
            if ( last != null ) {
                this.events.add( last );
            }

            // Add the current event on the end of the buffer
            this.events.add( first );

            return first;


        } else {
            // this.duration = 0;
        }

        return null;

    }



    void execute( int ticks ) {

        this.localTick += 1;

        controller.goBgaTo( 15, 1 );
        controller.goSpeedTo( 1, 3, 1 );

        controller.composition.muteOne();
        controller.composition.muteMultiple();

        // Turn itself off if exceeded the duration
        if ( this.localTick > this.duration ) {
            this.getStory().phase.holdPhaseActive( this.getStory().phase.multiple );
        }

    }

    void onEnd() {

        this.getStory().forEveryTool( (tool) -> {
            tool.eventOff();
        });

        if ( this.current != null ) {
            this.current.onDeactivate();
        }


    }

}
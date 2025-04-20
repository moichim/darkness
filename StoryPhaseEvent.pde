class StoryPhaseEvent extends StoryPhaseAbstract {

    PHASE key() {return PHASE.EVENT; }

    int code() { return 3; }

    void onActivate() {
        
        this.getStory().forEveryTool( (tool) -> {
            tool.eventOn();
        });

    }

    void execute( int ticks ) {

        controller.goBgaTo( 15, 1 );
        controller.goSpeedTo( 1, 3, 1 );

        controller.composition.muteOne();
        controller.composition.muteMultiple();

    }

    void onEnd() {

        this.getStory().forEveryTool( (tool) -> {
            tool.eventOff();
        });


    }

}
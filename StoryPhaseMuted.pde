class StoryPhaseMuted extends StoryPhaseAbstract {

    PHASE key() {return PHASE.MUTED; }

    int code() { return 0; }

    void onActivate() {

        this.getStory().forEveryTool( (tool) -> {
            tool.mutedOn();
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
            tool.mutedOff();
        });

    }

}
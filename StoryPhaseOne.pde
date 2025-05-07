class StoryPhaseOne extends StoryPhaseAbstract {

    StoryPhaseOne(
        Story story
    ) {
        super( story );
    }

    PHASE key() {return PHASE.ONE; }

    int code() { return 1; }

    void onActivate() {

        this.getStory().forEveryTool( (tool) -> {
            tool.oneOn();
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
            tool.oneOff();
        });

    }

}
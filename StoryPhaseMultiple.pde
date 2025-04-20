class StoryPhaseMultiple extends StoryPhaseAbstract {

    PHASE key() {return PHASE.MULTIPLE; }

    int code() { return 2; }

    void onActivate() {

        this.getStory().forEveryTool( (tool) -> {
            tool.multipleOn();
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
            tool.multipleOff();
        });


    }

}
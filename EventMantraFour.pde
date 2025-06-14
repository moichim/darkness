class EventMantraFour extends EventAbstract {

    public int getDuration() {
        return 2000;
    }

    EventMantraFour(
        Story story
    ) {
        super(story);
    }

    public int getCode() {
        return 3;
    }

    public void onInit() {

        
        
    }

    public void onActivate() {

        this.renderStart( color(0,255,0) );
        this.story.sendEventStart( this.getCode() );

        this.story.kytar.circle().on();
        this.story.kytar.circle().setImpact( 0.8 );
        this.story.kytar.circle().setNumber(5);

        // Show dense grid for sort time in long intervals
        EffectToggleGridOnJump toggleGrid = new EffectToggleGridOnJump(
            this.story.bell,
            7,
            5,
            40,
            TOGGLE_GRID.TOGGLE
        );
        toggleGrid.setImpact(0.9);
        toggleGrid.setDuration(4000);
        toggleGrid.setDelay(100);
        this.story.bell.addEffect( "grid", toggleGrid );
        this.story.bell.colors().setThreshold(200);


        this.story.voice.colors().setThreshold(155);
        this.story.voice.round().on();
        this.story.voice.round().configure(6);

    }

    public void onDeactivate() {

        this.renderEnd( color(0,255,255) );
        this.story.sendEventEnd();

        this.story.kytar.circle().off();
        this.story.bell.removeEffect("grid");
        this.story.bell.colors().setThreshold(80);
        this.story.voice.colors().setThreshold(80);
        this.story.voice.round().off();

    }

}
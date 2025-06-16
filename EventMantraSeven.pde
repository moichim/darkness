class EventMantraSeven extends EventAbstract {

    public int getDuration() {
        return 2000;
    }

    PImage monkey;
    PImage flowers;

    EventMantraSeven(
        Story story
    ) {
        super(story);
        this.monkey = loadImage("normals/relief_dekor.png");
        this.flowers = loadImage( "normals/flower_grid.png" );
    }

    public int getCode() {
        return 7;
    }

    public void onInit() {

        
        
    }

    public void onActivate() {

        this.renderStart( color(0,255,0) );
        this.story.sendEventStart( this.getCode() );

        this.story.pulse.circle().on();
        this.story.pulse.circle().setImpact( 0.8 );
        this.story.kytar.circle().setNumber(80);

        this.story.pulse.random().setSpread(40);

        // Show dense grid for sort time in long intervals
        EffectToggleGridOnJump toggleGrid = new EffectToggleGridOnJump(
            this.story.bell,
            5,
            5,
            40,
            TOGGLE_GRID.TOGGLE
        );
        toggleGrid.setImpact(0.9);
        toggleGrid.setDuration(4000);
        toggleGrid.setDelay(100);
        this.story.bell.addEffect( "grid", toggleGrid );
        this.story.bell.colors().setThreshold(200);


        this.story.voice.normal().on();
        this.story.voice.normal().setImpact( 0.5 );
        this.story.voice.normal().setMap( this.flowers );


        this.story.pulse.circle().on();
        this.story.pulse.circle().setImpact( 0.6 );
        this.story.pulse.circle().setNumber(7);

        this.story.piano.normal().on();
        this.story.piano.normal().setImpact( 0.9 );
        this.story.piano.normal().setMap( this.monkey );

        this.story.angels.normal().on();
        this.story.angels.normal().setImpact( 0.7 );
        this.story.angels.normal().setMap( this.flowers );

    }

    public void onDeactivate() {

        this.renderEnd( color(0,255,255) );
        this.story.sendEventEnd();

        this.story.pulse.random().setSpread(12);

        this.story.pulse.circle().off();
        this.story.bell.removeEffect("grid");
        this.story.bell.colors().setThreshold(80);
        this.story.voice.normal().off();
        this.story.voice.round().off();
        this.story.pulse.circle().off();
        this.story.piano.normal().off();

    }

}